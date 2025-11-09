import SwiftUI
import FirebaseAuth

struct ChatView: View {
//    @EnvironmentObject var dbHelper: FireDBHelper
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

        VStack(spacing: 0) {

            // MARK: - Top bar
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(listingToShow.title)
                        .font(.headline)
                        .lineLimit(1)

                    Text("With: \(otherPartyName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isSoldOut {
                    Text("SOLD OUT")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(999)
                }

                Button {
                    showInfoSheet = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.title3)
                        .padding(.leading, 4)
                }
            }
            .padding()
            .background(Color(.systemGray6))

            Divider()

            // MARK: - Availability banner
            if isSoldOut {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text("This listing is SOLD OUT / no longer available.")
                        .font(.subheadline)
                }
                .foregroundColor(.white)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.9))
            }

            // MARK: - Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(groupMessagesByDate(chatVM.messages), id: \.0) { (dateString, messagesForDate) in
                            HStack {
                                Spacer()
                                Text(dateString)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.vertical, 6)
                                Spacer()
                            }

                            ForEach(messagesForDate) { message in
                                HStack(alignment: .bottom) {
                                    if message.senderId == Auth.auth().currentUser?.uid {
                                        Spacer()
                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text(message.text)
                                                .padding(10)
                                                .background(Color.blue.opacity(0.3))
                                                .foregroundColor(.black)
                                                .cornerRadius(12)

                                            if let timestamp = message.timestamp {
                                                Text(formatTime(timestamp))
                                                    .font(.caption2)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    } else {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(message.text)
                                                .padding(10)
                                                .background(Color.gray.opacity(0.4))
                                                .foregroundColor(.black)
                                                .cornerRadius(12)

                                            if let timestamp = message.timestamp {
                                                Text(formatTime(timestamp))
                                                    .font(.caption2)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        Spacer()
                                    }
                                }
                                .id(message.id ?? UUID().uuidString)
                            }
                        }
                    }
                    .padding(.horizontal)
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

            // MARK: - Input
            HStack {
                TextField(
                    isSoldOut ? "Listing is SOLD OUT" : "Type a message...",
                    text: $chatVM.newMessage
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
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
                        .foregroundColor(isSoldOut ? .gray : .blue)
                }
                .disabled(isSoldOut)
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(Color(.systemBackground))
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                // messages
                await chatVM.listenToMessages(conversationId: conversationId)
            }
            Task {
                // people
                await loadPeople()
            }
            Task {
                // 🔁 refresh listing so isAvailable is up-to-date
                if let fresh = try? await FireDBHelper.getInstance().fetchListing(byId: listing.id) {
                    await MainActor.run {
                        self.liveListing = fresh
                    }
                }
            }
        }
        .sheet(isPresented: $showInfoSheet) {
            ChatInfoSheet(
                listing: liveListing ?? listing,   // pass the fresh one
                landlord: landlord,
                tenant: tenant,
                dbHelper: FireDBHelper.getInstance()
//                dbHelper: dbHelper
            )
//            .environmentObject(dbHelper)
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

    // MARK: - Load landlord / tenant
    private func loadPeople() async {
        if landlord == nil {
            if let user = await FireDBHelper.getInstance().getUser(byUID: listing.landlordId) {
                await MainActor.run { landlord = user }
            }
        }

        if let uid = Auth.auth().currentUser?.uid,
           let user = await FireDBHelper.getInstance().getUser(byUID: uid) {
            await MainActor.run { tenant = user }
        }
    }

    // MARK: - Helpers
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


// MARK: - Sheet

struct ChatInfoSheet: View {
//    @EnvironmentObject var dbHelper: FireDBHelper
    let listing: Listing
    let landlord: AppUser?
    let tenant: AppUser?
    let dbHelper: FireDBHelper    // pass in explicitly


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
                            // 👇 availability indicator
                            Text(listing.isAvailable ? "Available" : "Not available / Sold out")
                                .font(.caption)
                                .foregroundColor(listing.isAvailable ? .green : .red)
                            Text("\(listing.street), \(listing.city), \(listing.province)")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }

                Section("Landlord") {
                    if let landlord {
                        UserRow(user: landlord, subtitle: "Listing owner")
                    } else {
                        Text("Loading landlord…").foregroundColor(.secondary)
                    }
                }

                Section("Tenant") {
                    if let tenant {
                        UserRow(user: tenant, subtitle: "Renter / you")
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
