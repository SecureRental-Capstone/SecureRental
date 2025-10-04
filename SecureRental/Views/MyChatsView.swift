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
            List(sortedConversations, id: \.id) { conversation in
                if let listing = listings[conversation.listingId],
//                   let otherUserId = conversation.participants.first(where: { $0 != Auth.auth().currentUser?.uid }),
//                   let otherUser = users[otherUserId],
                    let landlord = users[listing.landlordId],
                   let lastMessage = lastMessages[conversation.id ?? ""] {
                    
                    NavigationLink(destination: ChatView(listing: listing)) {
                        HStack(alignment: .top, spacing: 12) {
                            // First image of the listing
//                            WebImage(url: URL(string: listing.imageURLs.first ?? ""))
//                                .resizable()
//                                .placeholder(Image(systemName: "photo"))
//                                .scaledToFill()
//                                .frame(width: 100, height: 100)
//                                .cornerRadius(10)

                            if let firstURL = listing.imageURLs.first,
                               let url = URL(string: firstURL) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 100, height: 100)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipped()
                                            .cornerRadius(10)
                                    case .failure(_):
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                            .foregroundColor(.gray)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }
                            else {
                                Image(systemName: "house")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)
                            }

                            VStack(alignment: .leading, spacing: 4) {
//                                Text("\(otherUser.name) – \(listing.title)")
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
            // If today → show only time (e.g., "12:36 AM")
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if let daysAgo = calendar.dateComponents([.day], from: date, to: Date()).day, daysAgo < 7 {
            // If within the past 7 days → show weekday (e.g., "Monday")
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        } else {
            // Otherwise show date (e.g., "Sep 21, 2025")
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
                    
//                    // Fetch other user
//                    if let otherUserId = conv.participants.first(where: { $0 != currentUserId }),
//                       users[otherUserId] == nil,
//                       let user = await FireDBHelper.getInstance().getUser(byUID: otherUserId) {
//                        DispatchQueue.main.async { users[otherUserId] = user }
//                    }

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
