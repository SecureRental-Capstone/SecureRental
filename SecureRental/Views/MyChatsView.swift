import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct MyChatsView: View {
    @StateObject private var viewModel = ConversationsViewModel()

    @State private var listings: [String: Listing] = [:]
    @State private var users: [String: AppUser] = [:]
    @State private var lastMessages: [String: ChatMessage] = [:]

    @State private var isInitialLoading = true

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color.hunterGreen.opacity(0.06),
                        Color(.systemBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 10) {
                    // HEADER SUMMARY
                    if !isInitialLoading {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Your conversations")
                                    .font(.headline)
                                Text("\(filteredConversations.count) active \(filteredConversations.count == 1 ? "chat" : "chats")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 6)
                    }

                    // CONTENT
                    Group {
                        if isInitialLoading {
                            // Skeleton loading
                            ScrollView {
                                VStack(spacing: 12) {
                                    ForEach(0..<5, id: \.self) { _ in
                                        SkeletonChatRow()
                                            .padding(.horizontal)
                                    }
                                }
                                .padding(.top, 16)
                            }
                            .transition(.opacity)
                        } else if filteredConversations.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                    .font(.system(size: 42))
                                    .foregroundColor(.gray.opacity(0.7))
                                Text("No conversations yet")
                                    .font(.headline)
                                Text("Start chatting with a landlord from a listing to see your messages here.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(filteredConversations, id: \.id) { conversation in
                                        if let listing = listings[conversation.listingId],
                                           let otherUserName = otherUserName(for: conversation, listing: listing),
                                           let lastMessage = lastMessages[conversation.id ?? ""] {

                                            NavigationLink {
                                                ChatView(
                                                    listing: listing,
                                                    conversationId: conversation.id ?? ""
                                                )
                                            } label: {
                                                ChatRowView(
                                                    listing: listing,
                                                    otherUserName: otherUserName,
//                                                    roleLabel: chatRoleLabel(for: conversation, listing: listing),
                                                    lastMessage: lastMessage
                                                )
                                                .padding(.horizontal)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                                .padding(.top, 8)
                            }
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.2), value: filteredConversations.count)
                        }
                    }
                }
            }
            .navigationTitle("My Chats")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                setupListeners()
            }
        }
    }

    // MARK: - Filter + Sort

    private var filteredConversations: [Conversation] {
        let withMessages = viewModel.conversations.filter { conv in
            if let id = conv.id {
                return lastMessages[id] != nil
            }
            return false
        }

        return withMessages.sorted {
            let t1 = lastMessages[$0.id ?? ""]?.timestamp ?? $0.createdAt ?? .distantPast
            let t2 = lastMessages[$1.id ?? ""]?.timestamp ?? $1.createdAt ?? .distantPast
            return t1 > t2
        }
    }

    // MARK: - Helpers

    private func otherUserName(for conversation: Conversation, listing: Listing) -> String? {
        guard let myId = Auth.auth().currentUser?.uid else { return nil }

        // If I'm landlord, show tenant; else show landlord
        if myId == listing.landlordId {
            if let tenantId = conversation.participants.first(where: { $0 != myId }),
               let tenant = users[tenantId] {
                return tenant.name
            } else {
                return "Tenant"
            }
        } else {
            return users[listing.landlordId]?.name ?? "Landlord"
        }
    }

//    private func chatRoleLabel(for conversation: Conversation, listing: Listing) -> String {
//        guard let myId = Auth.auth().currentUser?.uid else { return "" }
//        return myId == listing.landlordId ? "Tenant" : "Landlord"
//    }

    private func setupListeners() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        viewModel.listenForMyConversations(userId: currentUserId) { convs in
            // 1. Always update local list
            viewModel.conversations = convs

            // 2. As soon as we get the FIRST snapshot (even if empty),
            //    stop showing the skeleton and let UI show either:
            //    - "No conversations yet", or
            //    - the loaded conversations.
            Task { @MainActor in
                if isInitialLoading {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isInitialLoading = false
                    }
                }
            }

            // 3. Load metadata in the background (does NOT affect loading state)
            Task {
                await preloadMetadata(for: convs)
            }
        }
    }
 
        


    private func preloadMetadata(for convs: [Conversation]) async {
        for conv in convs {
            guard let convId = conv.id else { continue }

            // Listing + landlord/tenant
            if listings[conv.listingId] == nil,
               let listing = try? await FireDBHelper.getInstance().fetchListing(byId: conv.listingId) {

                await MainActor.run {
                    listings[conv.listingId] = listing
                }

                // landlord
                if users[listing.landlordId] == nil,
                   let landlord = await FireDBHelper.getInstance().getUser(byUID: listing.landlordId) {
                    await MainActor.run {
                        users[listing.landlordId] = landlord
                    }
                }
            }

            // tenant (if I'm landlord)
            if let myId = Auth.auth().currentUser?.uid,
               let listing = listings[conv.listingId],
               myId == listing.landlordId,
               let tenantId = conv.participants.first(where: { $0 != myId }),
               users[tenantId] == nil,
               let tenant = await FireDBHelper.getInstance().getUser(byUID: tenantId) {
                await MainActor.run {
                    users[tenantId] = tenant
                }
            }

            // Last message
//            if lastMessages[convId] == nil,
           if let lastMsg = try? await fetchLastMessage(conversationId: convId) {
                await MainActor.run {
                    lastMessages[convId] = lastMsg
                }
            }
        }
    }

    private func fetchLastMessage(conversationId: String) async throws -> ChatMessage? {
        let snapshot = try await Firestore.firestore()
            .collection("conversations")
            .document(conversationId)
            .collection("messages")
            .order(by: "timestamp", descending: true)
            .limit(to: 1)
            .getDocuments()

        return snapshot.documents.first.flatMap { try? $0.data(as: ChatMessage.self) }
    }
}

// MARK: - Chat Row

struct ChatRowView: View {
    let listing: Listing
    let otherUserName: String
    let lastMessage: ChatMessage

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Thumbnail
            if let firstURL = listing.imageURLs.first,
               let url = URL(string: firstURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 64, height: 64)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 64, height: 64)
                            .clipped()
                            .cornerRadius(10)
                    case .failure(_):
                        Image(systemName: "house.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 64, height: 64)
                            .foregroundColor(.gray.opacity(0.8))
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "house.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .foregroundColor(.gray.opacity(0.8))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(otherUserName)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)

//                    Text("•")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//
//                    Text(roleLabel)
//                        .font(.caption2)
//                        .padding(.horizontal, 6)
//                        .padding(.vertical, 3)
//                        .background(Color.hunterGreen.opacity(0.12))
//                        .foregroundColor(.hunterGreen)
//                        .clipShape(Capsule())

                    Spacer()

                    if let date = lastMessage.timestamp {
                        Text(formatDate(date))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                Text(listing.title)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(lastMessage.text)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }

    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()

        if calendar.isDateInToday(date) {
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if let daysAgo = calendar.dateComponents([.day], from: date, to: Date()).day,
                  daysAgo < 7 {
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        } else {
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
}

// MARK: - Skeleton Row

struct SkeletonChatRow: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.25))
                .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 14)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.22))
                    .frame(height: 12)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.20))
                    .frame(width: 80, height: 10)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
        )
        .shimmer()
    }
}
