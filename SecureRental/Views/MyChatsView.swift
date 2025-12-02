import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct MyChatsView: View {
    @StateObject private var viewModel = ConversationsViewModel()

    @State private var listings: [String: Listing] = [:]
    @State private var users: [String: AppUser] = [:]
    @State private var lastMessages: [String: ChatMessage] = [:]

    @State private var isInitialLoading = true
    @State private var searchText: String = ""
    
    @EnvironmentObject var vm: CurrencyViewModel

    var body: some View {
        NavigationView {
            ZStack {
                // Same style as HomeView background
                LinearGradient(
                    colors: [
                        Color.hunterGreen.opacity(0.06),
                        Color(.systemBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 12) {
                    // HEADER
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Messages")
                            .font(.title3.weight(.semibold))

                        Text(subtitleText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // SEARCH BAR (same style as Home search)
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.hunterGreen)
                        TextField("Search by name or listing…", text: $searchText)
                            .font(.subheadline)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    }
                    .padding(10)
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
                    .padding(.horizontal, 16)

                    if isInitialLoading {
                        // Skeletons styled like listing cards
                        ScrollView {
                            LazyVStack(spacing: 10) {
                                ForEach(0..<6, id: \.self) { _ in
                                    SkeletonChatRow()
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 4)
                            .padding(.bottom, 10)
                        }
                    } else if filteredConversations.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.gray.opacity(0.7))
                            Text("No conversations yet.")
                                .font(.body)
                                .foregroundColor(.primary)
                            Text("Start a chat from a listing to see your messages here.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 10) {   // 1 card per row
                                ForEach(filteredConversations, id: \.id) { conversation in
                                    if let listing = listings[conversation.listingId],
                                       let otherUserName = otherUserName(for: conversation, listing: listing),
                                       let lastMessage = lastMessages[conversation.id ?? ""] {

                                        NavigationLink {
                                            ChatView(
                                                listing: listing,
                                                conversationId: conversation.id ?? ""
                                            ).environmentObject(vm)
                                        } label: {
                                            ChatRowView(
                                                listing: listing,
                                                otherUserName: otherUserName,
                                                lastMessage: lastMessage
                                            ).environmentObject(vm)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 4)
                            .padding(.bottom, 10)
                        }
                        .animation(.easeInOut(duration: 0.2), value: filteredConversations.count)
                    }
                }
            }
            .navigationTitle("Messages")
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

        let sorted = withMessages.sorted {
            let t1 = lastMessages[$0.id ?? ""]?.timestamp ?? $0.createdAt ?? .distantPast
            let t2 = lastMessages[$1.id ?? ""]?.timestamp ?? $1.createdAt ?? .distantPast
            return t1 > t2
        }

        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return sorted }

        let query = trimmed.lowercased()
        return sorted.filter { conv in
            guard let listing = listings[conv.listingId] else { return false }
            let titleMatch = listing.title.lowercased().contains(query)
            let otherName = otherUserName(for: conv, listing: listing)?.lowercased() ?? ""
            let nameMatch = otherName.contains(query)
            return titleMatch || nameMatch
        }
    }

    private var subtitleText: String {
        let count = filteredConversations.count
        if count == 0 { return "You don’t have any chats yet." }
        if count == 1 { return "You have 1 active conversation." }
        return "You have \(count) active conversations."
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

    private func setupListeners() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        viewModel.listenForMyConversations(userId: currentUserId) { convs in
            viewModel.conversations = convs

            Task {
                await preloadMetadata(for: convs)

                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isInitialLoading = false
                    }
                }
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


struct ChatRowView: View {
    let listing: Listing
    let otherUserName: String
    let lastMessage: ChatMessage
    
    @EnvironmentObject var currencyManager: CurrencyViewModel

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail matching ListingCardView
            ZStack {
                if let firstURL = listing.imageURLs.first,
                   let url = URL(string: firstURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            Image(systemName: "house.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.gray.opacity(0.7))
                                .padding(12)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "house.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray.opacity(0.7))
                        .padding(12)
                }
            }
            .frame(width: 110, height: 90)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Text block
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(otherUserName)
                        .font(.footnote.weight(.semibold))
                        .lineLimit(1)

                    Spacer()

                    if let date = lastMessage.timestamp {
                        Text(formatDate(date))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                Text(listing.title)
                    .font(.footnote.weight(.semibold))
                    .lineLimit(2)

                // Location + price row
                HStack(spacing: 4) {
                    if !listing.city.isEmpty {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(listing.city), \(listing.province)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    // ✅ works whether price is Int, Double, or String
                    if let priceText = formattedPrice(listing.price) {
//                        Text(priceText)
                        Text(currencyManager.convertedPrice(basePriceString: listing.price) + "/mo")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(Color(red: 0.1, green: 0.5, blue: 0.2))
                    }
                }

                Text(lastMessage.text)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        )
    }

    private func formattedPrice(_ price: Any?) -> String? {
        // Adjust depending on your model type
        if let p = price as? Double {
            return "$\(Int(p))/mo"
        } else if let p = price as? Int {
            return "$\(p)/mo"
        } else if let p = price as? String, !p.isEmpty {
            return "$\(p)/mo"
        }
        return nil
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

struct SkeletonChatRow: View {
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.hunterGreen.opacity(0.12))
                .frame(width: 110, height: 90)

            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 14)

                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 10)

                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.18))
                    .frame(width: 110, height: 8)

                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.16))
                    .frame(width: 140, height: 8)
            }

            Spacer()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
        )
        .shimmer()
    }
}
