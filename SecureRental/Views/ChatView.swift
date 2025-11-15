import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ChatView: View {
    @StateObject var chatVM = ChatViewModel()

    // passed in
    let listing: Listing
    let conversationId: String

    // live / refreshed listing
    @State private var liveListing: Listing?

    @State private var showInfoSheet = false
    @State private var landlord: AppUser?
    @State private var tenant: AppUser?

    var body: some View {
        let listingToShow = liveListing ?? listing
        let isSoldOut = listingToShow.isAvailable == false

        ZStack {
            // Background matches HomeView / MyChatsView
            LinearGradient(
                colors: [
                    Color.hunterGreen.opacity(0.06),
                    Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: - Top bar (card style)
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(listingToShow.title)
                            .font(.subheadline.weight(.semibold))
                            .lineLimit(1)

                        Text("Chat with \(otherPartyName)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    if isSoldOut {
                        Text("SOLD OUT")
                            .font(.caption2.weight(.bold))
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color.red.opacity(0.9))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }

                    Button {
                        showInfoSheet = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.title3)
                            .foregroundColor(.hunterGreen)
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                )

                // MARK: - Availability banner
                if isSoldOut {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text("This listing is SOLD OUT / no longer available.")
                            .font(.caption)
                            .lineLimit(2)
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.95))
                }

                // MARK: - Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 10) {
                            ForEach(groupMessagesByDate(chatVM.messages), id: \.0) { (dateString, messagesForDate) in
                                // Date chip
                                HStack {
                                    Spacer()
                                    Text(dateString)
                                        .font(.caption2.weight(.semibold))
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(Color(.systemBackground).opacity(0.9))
                                                .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                                        )
                                    Spacer()
                                }
                                .padding(.top, 4)

                                ForEach(messagesForDate) { message in
                                    messageBubble(message)
                                        .id(message.id ?? UUID().uuidString)
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                    }
                    .onChange(of: chatVM.messages.count) { _ in
                        if let last = chatVM.messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id ?? UUID().uuidString, anchor: .bottom)
                            }
                        }
                    }
                }

                // MARK: - Input bar
                VStack(spacing: 0) {
                    Divider()

                    HStack(spacing: 8) {
                        TextField(
                            isSoldOut ? "Listing is SOLD OUT" : "Type a message...",
                            text: $chatVM.newMessage
                        )
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color(.systemGray6))
                        )
                        .font(.subheadline)
                        .disabled(isSoldOut)

                        Button {
                            Task {
                                let text = chatVM.newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                                guard !text.isEmpty else { return }
                                await chatVM.sendMessage(to: conversationId, text: text)
                                chatVM.newMessage = ""
                            }
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(
                                    Circle()
                                        .fill(isSoldOut ? Color.gray.opacity(0.4) : Color.hunterGreen)
                                )
                        }
                        .disabled(isSoldOut)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Color(.systemBackground)
                            .ignoresSafeArea(edges: .bottom)
                    )
                }

            }
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await chatVM.listenToMessages(conversationId: conversationId)
            }
            Task {
                await loadPeople()
            }
            Task {
                if let fresh = try? await FireDBHelper.getInstance().fetchListing(byId: listing.id) {
                    await MainActor.run {
                        self.liveListing = fresh
                    }
                }
            }
        }
        .sheet(isPresented: $showInfoSheet) {
            ChatInfoSheet(
                listing: liveListing ?? listing,
                landlord: landlord,
                tenant: tenant,
                dbHelper: FireDBHelper.getInstance()
            )
        }
    }

    // MARK: - Bubble builder

    @ViewBuilder
    private func messageBubble(_ message: ChatMessage) -> some View {
        let isMe = message.senderId == Auth.auth().currentUser?.uid

        HStack(alignment: .bottom, spacing: 6) {
            if isMe { Spacer() }

            VStack(alignment: isMe ? .trailing : .leading, spacing: 3) {
                Text(message.text)
                    .font(.subheadline)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(isMe
                                  ? Color.hunterGreen.opacity(0.90)
                                  : Color(.systemGray5))
                    )
                    .foregroundColor(isMe ? .white : .primary)

                if let timestamp = message.timestamp {
                    Text(formatTime(timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            if !isMe { Spacer() }
        }
        .transition(.opacity.combined(with: .move(edge: isMe ? .trailing : .leading)))
    }

    // MARK: - Derived

    private var otherPartyName: String {
        let myId = Auth.auth().currentUser?.uid
        if myId == listing.landlordId {
            return tenant?.name ?? "Tenant"
        } else {
            return landlord?.name ?? "Landlord"
        }
    }

    // MARK: - Load landlord / tenant

    private func loadPeople() async {
        guard let myId = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()

        do {
            let convDoc = try await db.collection("conversations")
                .document(conversationId)
                .getDocument()

            guard let data = convDoc.data(),
                  let participants = data["participants"] as? [String] else {
                print("❌ No participants for conversation")
                return
            }

            if myId == listing.landlordId {
                // I am landlord
                if let meUser = await FireDBHelper.getInstance().getUser(byUID: myId) {
                    await MainActor.run { self.landlord = meUser }
                }

                if let tenantId = participants.first(where: { $0 != myId }),
                   let tenantUser = await FireDBHelper.getInstance().getUser(byUID: tenantId) {
                    await MainActor.run { self.tenant = tenantUser }
                }
            } else {
                // I am tenant
                if let meUser = await FireDBHelper.getInstance().getUser(byUID: myId) {
                    await MainActor.run { self.tenant = meUser }
                }

                if let landlordUser = await FireDBHelper.getInstance().getUser(byUID: listing.landlordId) {
                    await MainActor.run { self.landlord = landlordUser }
                }
            }
        } catch {
            print("❌ Failed to load people: \(error.localizedDescription)")
        }
    }

    // MARK: - Helpers (same logic, just grouped)

    func groupMessagesByDate(_ messages: [ChatMessage]) -> [(String, [ChatMessage])] {
        let calendar = Calendar.current

        let grouped = Dictionary(grouping: messages) { message -> String in
            guard let date = message.timestamp else { return "Unknown" }

            if calendar.isDateInToday(date) {
                return "Today"
            } else if calendar.isDateInYesterday(date) {
                return "Yesterday"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "d MMM yyyy"
                return formatter.string(from: date)
            }
        }

        let sortedKeys = grouped.keys.sorted { key1, key2 in
            dateFromString(key1) ?? .distantPast < dateFromString(key2) ?? .distantPast
        }

        return sortedKeys.map { ($0, grouped[$0] ?? []) }
    }

    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    func dateFromString(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"

        if string == "Today" { return Date() }
        if string == "Yesterday" {
            return Calendar.current.date(byAdding: .day, value: -1, to: Date())
        }
        return formatter.date(from: string)
    }
}

struct ChatInfoSheet: View {
    let listing: Listing
    let landlord: AppUser?
    let tenant: AppUser?
    let dbHelper: FireDBHelper

    private var landlordSectionTitle: String {
        guard let current = Auth.auth().currentUser?.uid else { return "Landlord" }
        return current == listing.landlordId ? "Landlord (You)" : "Landlord"
    }

    private var tenantSectionTitle: String {
        guard let current = Auth.auth().currentUser?.uid else { return "Tenant" }
        return current == listing.landlordId ? "Tenant" : "Tenant (You)"
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Match app background
                LinearGradient(
                    colors: [
                        Color.hunterGreen.opacity(0.06),
                        Color(.systemBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // MARK: - Listing Card
                        NavigationLink {
                            RentalListingDetailView(listing: listing)
                                .environmentObject(dbHelper)
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 12) {
                                    // Thumbnail (similar to ListingCardView)
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
                                    .frame(width: 90, height: 72)
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(listing.title)
                                            .font(.subheadline.weight(.semibold))
                                            .lineLimit(2)

                                        Text("$\(listing.price)/month")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundColor(.hunterGreen)

                                        HStack(spacing: 4) {
                                            Image(systemName: "mappin.and.ellipse")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                            Text("\(listing.city), \(listing.province)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                        }
                                    }

                                    Spacer()
                                }

                                HStack {
                                    Text(listing.isAvailable ? "Available" : "Not available / Sold out")
                                        .font(.caption.weight(.semibold))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(
                                                    listing.isAvailable
                                                    ? Color.hunterGreen.opacity(0.12)
                                                    : Color.red.opacity(0.12)
                                                )
                                        )
                                        .foregroundColor(
                                            listing.isAvailable
                                            ? .hunterGreen
                                            : .red
                                        )

                                    Spacer()
                                }
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.06),
                                            radius: 4, x: 0, y: 2)
                            )
                        }
                        .buttonStyle(.plain)

                        // MARK: - Landlord Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text(landlordSectionTitle)
                                .font(.subheadline.weight(.semibold))

                            if let landlord {
                                NavigationLink {
                                    LandlordProfileView(landlord: landlord)
                                } label: {
                                    cardWrapper {
                                        UserRow(user: landlord)
                                    }
                                }
                                .buttonStyle(.plain)
                            } else {
                                cardWrapper {
                                    HStack {
                                        ProgressView()
                                        Text("Loading landlord…")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)

                        // MARK: - Tenant Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text(tenantSectionTitle)
                                .font(.subheadline.weight(.semibold))

                            if let tenant {
                                cardWrapper {
                                    UserRow(user: tenant)
                                }
                            } else {
                                cardWrapper {
                                    HStack {
                                        ProgressView()
                                        Text("Loading tenant…")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)

                        Spacer(minLength: 8)
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                }
            }
            .navigationTitle("Chat Info")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Small helper for consistent cards
    @ViewBuilder
    private func cardWrapper<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05),
                            radius: 3, x: 0, y: 1)
            )
    }
}



struct UserRow: View {
    let user: AppUser
    var subtitle: String?

    var body: some View {
        HStack(spacing: 12) {
            if let urlString = user.profilePictureURL,
               !urlString.isEmpty,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView().frame(width: 46, height: 46)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 46, height: 46)
                            .clipShape(Circle())
                    case .failure:
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 46, height: 46)
                            .overlay(Image(systemName: "person.fill"))
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 46, height: 46)
                    .overlay(Image(systemName: "person.fill"))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(user.name)
                    .font(.body)

                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                let rating = user.rating ?? 0
                if rating > 0 {
                    HStack(spacing: 2) {
                        ForEach(0..<5, id: \.self) { idx in
                            Image(systemName: idx < Int(rating.rounded()) ? "star.fill" : "star")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                        }
                        Text(String(format: "%.1f", rating))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
