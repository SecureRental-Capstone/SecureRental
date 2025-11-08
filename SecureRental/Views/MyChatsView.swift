import SwiftUI
import FirebaseAuth
import FirebaseFirestore
//import SDWebImageSwiftUI

struct MyChatsView: View {
    @StateObject private var viewModel = ConversationsViewModel()
    @State private var listings: [String: Listing] = [:]
    @State private var users: [String: AppUser] = [:]
    @State private var lastMessages: [String: ChatMessage] = [:] // conversationId -> last message

    var body: some View {
        NavigationView {
            Group {
                if sortedConversations.isEmpty {
                    // 👉 Empty state
                    VStack(spacing: 12) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.6))
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
                    // 👉 Actual list of conversations
                    List(sortedConversations, id: \.id) { conversation in
                        if let listing = listings[conversation.listingId],
                           let landlord = users[listing.landlordId],
                           let lastMessage = lastMessages[conversation.id ?? ""] {
                            
                            NavigationLink(destination: ChatView(listing: listing)) {
                                HStack(alignment: .top, spacing: 12) {
                                    // listing image
                                    if let firstURL = listing.imageURLs.first,
                                       let url = URL(string: firstURL) {
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                                    .frame(width: 70, height: 70)
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 70, height: 70)
                                                    .clipped()
                                                    .cornerRadius(8)
                                            case .failure(_):
                                                Image(systemName: "house")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 70, height: 70)
                                                    .foregroundColor(.gray)
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                    } else {
                                        Image(systemName: "house")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 70, height: 70)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(landlord.name) – \(listing.title)")
                                            .font(.headline)
                                            .lineLimit(1)
                                        
                                        Text(lastMessage.text)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                        
                                        if let date = lastMessage.timestamp {
                                            Text(formatDate(date))
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        } else {
                            Text("Loading...")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("My Chats")
            .onAppear {
                setupListeners()
            }
        }
    }

    private var sortedConversations: [Conversation] {
        viewModel.conversations.sorted {
            let t1 = lastMessages[$0.id ?? ""]?.timestamp ?? $0.createdAt ?? Date.distantPast
            let t2 = lastMessages[$1.id ?? ""]?.timestamp ?? $1.createdAt ?? Date.distantPast
            return t1 > t2
        }
    }

    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()

        if calendar.isDateInToday(date) {
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if let daysAgo = calendar.dateComponents([.day], from: date, to: Date()).day, daysAgo < 7 {
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        } else {
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: date)
        }
    }

    private func setupListeners() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        viewModel.listenForMyConversations(userId: currentUserId) { convs in
            viewModel.conversations = convs

            for conv in convs {
                Task {
                    // Fetch listing
                    if listings[conv.listingId] == nil,
                       let listing = try? await FireDBHelper.getInstance().fetchListing(byId: conv.listingId) {
                        DispatchQueue.main.async { listings[conv.listingId] = listing }
                        
                        // Fetch landlord user for this listing
                        if users[listing.landlordId] == nil,
                           let landlord = await FireDBHelper.getInstance().getUser(byUID: listing.landlordId) {
                            DispatchQueue.main.async { users[listing.landlordId] = landlord }
                        }
                    }

                    // Fetch last message
                    if let lastMsg = try? await fetchLastMessage(conversationId: conv.id ?? "") {
                        DispatchQueue.main.async { lastMessages[conv.id ?? ""] = lastMsg }
                    }
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
