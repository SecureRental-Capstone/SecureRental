import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct MyChatsView: View {
    @StateObject private var streamVM = StreamConversationsViewModel()

    @State private var listings: [String: Listing] = [:]
    @State private var users: [String: AppUser] = [:]

    private let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            Group {
                if streamVM.channels.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.6))
                        Text("No conversations yet")
                            .font(.headline)
                        Text("Start chatting to see messages here.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        Section("Chats") {
                            ForEach(streamVM.channels, id: \.cid) { channel in
                                let listingId  = channel.extraData["listingId"]?.stringValue
                                let landlordId = channel.extraData["landlordId"]?.stringValue

                                NavigationLink {
                                    if
                                        let listingId = listingId,
                                        let listing = listings[listingId],
                                        let landlordId = landlordId
                                    {
                                        StreamChatDetailView(
                                            listing: listing,
                                            landlordId: landlordId,
                                            channelId: channel.cid.id    // 👈 pass it
                                        )
                                    } else {
                                        Text("Loading chat…")
                                    }
                                } label: {
                                    HStack(alignment: .top, spacing: 12) {
                                        if
                                            let listingId = listingId,
                                            let listing = listings[listingId],
                                            let firstURL = listing.imageURLs.first,
                                            let url = URL(string: firstURL)
                                        {
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
                                                case .failure:
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
                                            Text(channel.name ?? "Chat")
                                                .font(.headline)
                                                .lineLimit(1)

                                            if let last = channel.latestMessages.first {
                                                Text(last.text ?? "")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                                    .lineLimit(1)
                                            }

                                            if let date = channel.lastMessageAt {
                                                Text(formatDate(date))
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Chats")
            .onAppear {
                guard let uid = Auth.auth().currentUser?.uid else { return }

                // 1) landlord: pull Firestore convos and "join" them in Stream
                fetchMyStreamConversationsFromFirestore(currentUserId: uid)

                // 2) then load channels from Stream (now I should be a member)
                streamVM.loadMyChannels(currentUserId: uid)
            }
            .onChange(of: streamVM.channels) { _ in
                Task {
                    await prefetchListingsForStreamChannels()
                }
            }
        }
    }

    private func fetchMyStreamConversationsFromFirestore(currentUserId: String) {
        db.collection("streamConversations")
            .whereField("landlordId", isEqualTo: currentUserId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ failed to fetch streamConversations for landlord: \(error)")
                    return
                }

                snapshot?.documents.forEach { doc in
                    let data = doc.data()
                    guard
                        let channelId = data["channelId"] as? String,
                        let listingId = data["listingId"] as? String,
                        let landlordId = data["landlordId"] as? String,
                        let tenantId = data["tenantId"] as? String,
                        let listingTitle = data["listingTitle"] as? String
                    else { return }

                    // 👉 tell Stream to create/fetch this channel with BOTH members
//                    StreamChatManager.shared.ensureChannelForLandlord(
//                        channelId: channelId,
//                        listingId: listingId,
//                        landlordId: landlordId,
//                        tenantId: tenantId,
//                        listingTitle: listingTitle
//                    )
                }
            }
    }

    private func prefetchListingsForStreamChannels() async {
        for channel in streamVM.channels {
            guard let listingId = channel.extraData["listingId"]?.stringValue else { continue }

            if listings[listingId] == nil,
               let listing = try? await FireDBHelper.getInstance().fetchListing(byId: listingId) {
                await MainActor.run {
                    listings[listingId] = listing
                }

                if users[listing.landlordId] == nil,
                   let landlord = await FireDBHelper.getInstance().getUser(byUID: listing.landlordId) {
                    await MainActor.run {
                        users[listing.landlordId] = landlord
                    }
                }
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let f = DateFormatter()
        if calendar.isDateInToday(date) {
            f.dateFormat = "h:mm a"
            return f.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if let days = calendar.dateComponents([.day], from: date, to: Date()).day, days < 7 {
            f.dateFormat = "EEEE"
            return f.string(from: date)
        } else {
            f.dateFormat = "MMM d, yyyy"
            return f.string(from: date)
        }
    }
}
