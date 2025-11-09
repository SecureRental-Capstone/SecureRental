import SwiftUI
import FirebaseAuth

struct ChatView: View {
    @StateObject var chatVM = ChatViewModel()

    // you already had this
    var listing: Listing
    // new param we pass from MyChatsView / Detail
    let conversationId: String

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {

                        // group by date (your original logic)
                        ForEach(groupMessagesByDate(chatVM.messages), id: \.0) { (dateString, messagesForDate) in

                            // date header
                            HStack {
                                Spacer()
                                Text(dateString)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.vertical, 6)
                                Spacer()
                            }

                            // messages for that date
                            ForEach(messagesForDate) { message in
                                HStack(alignment: .bottom) {
                                    if message.senderId == Auth.auth().currentUser?.uid {
                                        // current user bubble
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
                                        // other user bubble
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
                    .padding()
                }
                .onChange(of: chatVM.messages.count) { _ in
                    // scroll to bottom on new message
                    if let last = chatVM.messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id ?? UUID().uuidString, anchor: .bottom)
                        }
                    }
                }
            }

            // input field
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
            .padding()
        }
        .navigationTitle("Chat")
        .onAppear {
            Task {
                await chatVM.listenToMessages(conversationId: conversationId)
            }
        }
    }

    // MARK: - Helper Functions (kept from your original code)

    /// Group messages by date (Today, Yesterday, or a formatted date)
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

        // sort sections by actual date
        let sortedKeys = grouped.keys.sorted { key1, key2 in
            dateFromString(key1) ?? .distantPast < dateFromString(key2) ?? .distantPast
        }

        return sortedKeys.map { ($0, grouped[$0] ?? []) }
    }

    /// Format a single timestamp (e.g. “12:28 AM”)
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    /// Convert section header (Today / Yesterday / date) to Date for sorting
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
