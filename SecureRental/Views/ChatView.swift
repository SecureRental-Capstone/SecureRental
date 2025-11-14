import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// MARK: - Chat View

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
        // use the live listing if we have it, otherwise fallback to the passed one
        let listingToShow = liveListing ?? listing
        let isSoldOut = listingToShow.isAvailable == false

        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color.hunterGreen.opacity(0.05),
                    Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: - Top bar
                HStack(spacing: 12) {

                    // Small thumbnail
                    if let firstURL = listingToShow.imageURLs.first,
                       let url = URL(string: firstURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 40, height: 40)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            case .failure:
                                Image(systemName: "house.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.gray.opacity(0.7))
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Image(systemName: "house.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray.opacity(0.7))
                    }

                    VStack(alignment: .leading, spacing: 4) {

                        Text(listingToShow.title)
                            .font(.subheadline.weight(.semibold))
                            .lineLimit(1)

                        Text("With \(otherPartyName)")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        // Only show this IF user is landlord
                        if isLandlord {
                            landlordBadge
                        }
                    }


                    Spacer()

                    if isSoldOut {
                        Text("SOLD OUT")
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red)
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
                .padding()
                .background(
                    Color(.systemBackground)
                        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                )

                // MARK: - Availability banner
                if isSoldOut {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text("This listing is SOLD OUT / no longer available.")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.9))
                }

                // MARK: - Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 10) {
                            let sections = makeSections(from: chatVM.messages)

                            ForEach(sections) { section in
                                // Date chip
                                HStack {
                                    Spacer()
                                    Text(section.title)
                                        .font(.caption2)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color(.systemGray5))
                                        .foregroundColor(.secondary)
                                        .clipShape(Capsule())
                                    Spacer()
                                }
                                .padding(.vertical, 4)

                                // Messages for this date
                                ForEach(section.messages) { message in
                                    messageBubble(for: message)
                                }
                            }
                        }

                        .padding(.horizontal, 12)
                        .padding(.top, 8)
                        .padding(.bottom, 6)
                    }
//                    .transaction { txn in
//                            txn.disablesAnimations = true
//                        }
//                    .onChange(of: chatVM.messages.count) { _ in
//                        if let last = chatVM.messages.last {
//                                proxy.scrollTo(last.id ?? UUID().uuidString, anchor: .bottom)
//                        }
//                    }
                }

                // MARK: - Input
                HStack(spacing: 8) {
                    TextField(
                        isSoldOut ? "Listing is SOLD OUT" : "Type a message…",
                        text: $chatVM.newMessage,
                        axis: .vertical
                    )
                    .lineLimit(1...4)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
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
                            .background(isSoldOut ? Color.gray : Color.hunterGreen)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.12), radius: 3, x: 0, y: 1)
                    }
                    .disabled(isSoldOut)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await chatVM.listenToMessages(conversationId: conversationId)
            }
            Task {
                await loadPeople()
            }
            Task {
                // refresh listing so isAvailable is up-to-date
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

    // MARK: - Derived

    private var otherPartyName: String {
        let myId = Auth.auth().currentUser?.uid
        if myId == listing.landlordId {
            return tenant?.name ?? "Tenant"
        } else {
            return landlord?.name ?? "Landlord"
        }
    }
    
    private var isLandlord: Bool {
        Auth.auth().currentUser?.uid == listing.landlordId
    }

    private var landlordBadge: some View {
        Text("You are the landlord")
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule().fill(Color.hunterGreen.opacity(0.15))
            )
            .foregroundColor(.hunterGreen)
    }


    // MARK: - Message bubble builder

    @ViewBuilder
    private func messageBubble(for message: ChatMessage) -> some View {
        let isMe = message.senderId == Auth.auth().currentUser?.uid

        HStack {
            if isMe { Spacer() }

            VStack(alignment: isMe ? .trailing : .leading, spacing: 2) {
                Text(message.text)
                    .font(.subheadline)
                    .padding(10)
                    .background(
                        isMe
                        ? Color.hunterGreen
                        : Color(.systemGray5)
                    )
                    .foregroundColor(isMe ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                if let timestamp = message.timestamp {
                    Text(formatTime(timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: isMe ? .trailing : .leading)

            if !isMe { Spacer() }
        }
        .padding(.vertical, 2)
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
                // I am landlord → landlord = me, tenant = other
                if let meUser = await FireDBHelper.getInstance().getUser(byUID: myId) {
                    await MainActor.run { self.landlord = meUser }
                }

                if let tenantId = participants.first(where: { $0 != myId }),
                   let tenantUser = await FireDBHelper.getInstance().getUser(byUID: tenantId) {
                    await MainActor.run { self.tenant = tenantUser }
                }
            } else {
                // I am tenant → tenant = me, landlord = listing.landlordId
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

    // MARK: - Helpers
    // Group messages into stable sections
    func makeSections(from messages: [ChatMessage]) -> [MessageSection] {
        let calendar = Calendar.current

        let weekdayFormatter = DateFormatter()
        weekdayFormatter.dateFormat = "EEE"              // Sat, Sun, Mon...

        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateFormat = "MMM d, yyyy"     // Oct 5, 2024

        // 1. Sort messages so ordering is consistent
        let sortedMessages = messages.sorted {
            ($0.timestamp ?? .distantPast) < ($1.timestamp ?? .distantPast)
        }

        // 2. Group by start-of-day Date (stable key)
        let grouped = Dictionary(grouping: sortedMessages) { message -> Date in
            let date = message.timestamp ?? Date()
            return calendar.startOfDay(for: date)
        }

        // 3. Sort section days ascending (oldest → newest)
        let sortedDays = grouped.keys.sorted()

        // 4. Build MessageSection objects
        return sortedDays.map { day in
            let msgs = grouped[day] ?? []

            // How many days ago is this section?
            let daysAgo = calendar.dateComponents([.day], from: day, to: Date()).day ?? 0

            let title: String
            if calendar.isDateInToday(day) {
                title = "Today"
            } else if calendar.isDateInYesterday(day) {
                title = "Yesterday"
            } else if daysAgo < 7 {
                // within last 7 days → weekday only: "Sat", "Sun", ...
                title = weekdayFormatter.string(from: day)
            } else {
                // older than 7 days → full date
                title = fullDateFormatter.string(from: day)
            }

            return MessageSection(
                id: day,
                date: day,
                title: title,
                messages: msgs
            )
        }
    }

    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

}

// MARK: - Chat Info Sheet

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
            List {
                Section("Listing") {
                    NavigationLink {
                        RentalListingDetailView(listing: listing)
                            .environmentObject(dbHelper)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(listing.title)
                                .font(.headline)
                            Text("$\(listing.price)/month")
                                .font(.subheadline)
                                .foregroundColor(.hunterGreen)
                            Text(listing.isAvailable ? "Available" : "Not available / Sold out")
                                .font(.caption)
                                .foregroundColor(listing.isAvailable ? .green : .red)
                            Text("\(listing.street), \(listing.city), \(listing.province)")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }

                Section(header: Text(landlordSectionTitle)) {
                    if let landlord {
                        NavigationLink {
                            LandlordProfileView(landlord: landlord)
                        } label: {
                            UserRow(user: landlord)
                        }
                    } else {
                        Text("Loading landlord…").foregroundColor(.secondary)
                    }
                }

                Section(header: Text(tenantSectionTitle)) {
                    if let tenant {
                        UserRow(user: tenant)
                    } else {
                        Text("Loading tenant…").foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Chat Info")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - User Row

struct UserRow: View {
    let user: AppUser
    var subtitle: String? = nil

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
                        placeholderAvatar
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                placeholderAvatar
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

    private var placeholderAvatar: some View {
        Circle()
            .fill(Color.gray.opacity(0.25))
            .frame(width: 46, height: 46)
            .overlay(
                Image(systemName: "person.fill")
                    .foregroundColor(.white)
            )
    }
}

struct MessageSection: Identifiable {
    let id: Date          // start-of-day date
    let date: Date
    let title: String     // "Today", "Yesterday", "Sat", "Oct 5, 2024"
    let messages: [ChatMessage]
}
