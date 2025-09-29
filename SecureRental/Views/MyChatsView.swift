import SwiftUI
import FirebaseAuth

struct MyChatsView: View {
    @StateObject private var viewModel = ConversationsViewModel()
    @State private var listings: [String: Listing] = [:] // Map listingId -> Listing

    var body: some View {
        NavigationView {
            List(viewModel.conversations, id: \.id) { conversation in
                if let listing = listings[conversation.listingId] {
                    NavigationLink(destination: ChatView(listing: listing)) {
                        VStack(alignment: .leading) {
                            Text(listing.title)
                                .font(.headline)
                            let otherUserId = conversation.participants.first { $0 != Auth.auth().currentUser?.uid }
                            Text("Chat with \(otherUserId ?? "Landlord/Tenant")")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
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

    private func setupListeners() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        // Real-time listener for conversations
        viewModel.listenForMyConversations(userId: currentUserId) { convs in
            viewModel.conversations = convs

            // Fetch related listings dynamically
            for conv in convs {
                if listings[conv.listingId] == nil {
                    Task {
                        if let listing = try? await FireDBHelper.getInstance().fetchListing(byId: conv.listingId) {
                            DispatchQueue.main.async {
                                listings[conv.listingId] = listing
                            }
                        }
                    }
                }
            }
        }
    }
}
