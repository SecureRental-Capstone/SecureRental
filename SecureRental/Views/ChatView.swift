import SwiftUI
import FirebaseAuth

struct ChatView: View {
    @EnvironmentObject var dbHelper: FireDBHelper      // 👈 so we can pass it down
    @StateObject var chatVM = ChatViewModel()

    var listing: Listing
    let conversationId: String

    // info state
    @State private var showInfoSheet = false
    @State private var landlord: AppUser?
    @State private var tenant: AppUser?

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Top context bar
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(listing.title)
                        .font(.headline)
                        .lineLimit(1)

                    Text("With: \(otherPartyName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button {
                    showInfoSheet = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.title3)
                }
                .accessibilityLabel("Show chat info")
            }
            .padding()
            .background(Color(.systemGray6))

            Divider()

            // MARK: - Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {

                        ForEach(groupMessagesByDate(chatVM.messages), id: \.0) { (dateString, messagesForDate) in

                            // Date header
                            HStack {
                                Spacer()
                                Text(dateString)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.vertical, 6)
                                Spacer()
                            }

                            // Messages
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

            // MARK: - Input field
            HStack {
                TextField("Type a message...", text: $chatVM.newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button {
                    Task {
                        let text = chatVM.newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !text.isEmpty else { return }
                        await chatVM.sendMessage(to: conversationId, text: text)
                        chatVM.newMessage = ""
                    }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(Color(.systemBackground))
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
        }
        .sheet(isPresented: $showInfoSheet) {
            ChatInfoSheet(
                listing: listing,
                landlord: landlord,
                tenant: tenant
            )
            .environmentObject(dbHelper)   // 👈 so detail view can use it
        }
    }

    // MARK: - Derived
    private var otherPartyName: String {
        let myId = Auth.auth().currentUser?.uid
        if myId == listing.landlordId {
            // I'm the landlord, so show tenant
            return tenant?.name ?? "Tenant"
        } else {
            return landlord?.name ?? "Landlord"
        }
    }

    // MARK: - Load landlord / tenant
    private func loadPeople() async {
        // landlord
        if landlord == nil {
            if let user = await FireDBHelper.getInstance().getUser(byUID: listing.landlordId) {
                await MainActor.run { landlord = user }
            }
        }

        // tenant is current user
        if let uid = Auth.auth().currentUser?.uid,
           let user = await FireDBHelper.getInstance().getUser(byUID: uid) {
            await MainActor.run { tenant = user }
        }
    }

    // MARK: - Helpers (same as before)
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
    @EnvironmentObject var dbHelper: FireDBHelper   // so we can pass to detail
    let listing: Listing
    let landlord: AppUser?
    let tenant: AppUser?

    var body: some View {
        NavigationView {
            List {
                // Listing
                Section("Listing") {
                    NavigationLink {
                        RentalListingDetailView(listing: listing)
                            .environmentObject(dbHelper)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(listing.title)
                                .font(.headline)
                            Text("$\(listing.price)/month")
                            Text("\(listing.street), \(listing.city), \(listing.province)")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }

                // Landlord
                Section("Landlord") {
                    if let landlord {
                        UserRow(user: landlord, subtitle: "Listing owner")
                    } else {
                        Text("Loading landlord…")
                            .foregroundColor(.secondary)
                    }
                }

                // Tenant / You
                Section("Tenant") {
                    if let tenant {
                        UserRow(user: tenant, subtitle: "Renter / you")
                    } else {
                        Text("Loading tenant…")
                            .foregroundColor(.secondary)
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
            // avatar
            if let urlString = user.profilePictureURL,
               !urlString.isEmpty,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 46, height: 46)
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

                // rating if present
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
