//
//  ChatView.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-09-21.
//
//

import SwiftUI
import FirebaseAuth

struct ChatView: View {
    @StateObject var chatVM = ChatViewModel()
    var listing: Listing

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        // Group messages by date
                        ForEach(groupMessagesByDate(chatVM.messages), id: \.0) { (dateString, messagesForDate) in
                            // Date Header
                            HStack {
                                Spacer()
                                Text(dateString)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.vertical, 6)
                                Spacer()
                            }

                            // Messages for that date
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
                    .padding()
                }
                .onChange(of: chatVM.messages.count) { _ in
                    if let last = chatVM.messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id ?? UUID().uuidString, anchor: .bottom)
                        }
                    }
                }
            }

            // Input field
            HStack {
                TextField("Type a message...", text: $chatVM.newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    Task { await chatVM.sendMessage() }
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
        .navigationTitle("Chat")
        .onAppear {
            Task {
                await chatVM.startConversation(
                    listingId: listing.id,
                    landlordId: listing.landlordId
                )
            }
        }
    }

    // MARK: - Helper Functions

    /// Groups messages by date (e.g., Today, Yesterday, or a formatted date)
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

        // Sort groups by date ascending
        let sortedKeys = grouped.keys.sorted { key1, key2 in
            dateFromString(key1) ?? Date.distantPast < dateFromString(key2) ?? Date.distantPast
        }

        return sortedKeys.map { ($0, grouped[$0] ?? []) }
    }

    /// Formats a single timestamp (e.g., “12:28 AM”)
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    /// Converts group header string (Today, Yesterday, or date) to Date for sorting
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


//
//import SwiftUI
//import FirebaseAuth
//
//struct ChatView: View {
//    @StateObject var chatVM = ChatViewModel()
//    var listing: Listing
//
//    var body: some View {
//        VStack {
//            ScrollView {
//                LazyVStack(alignment: .leading, spacing: 8) {
//                    ForEach(chatVM.messages) { message in
//                        HStack {
//                            if message.senderId == Auth.auth().currentUser?.uid {
//                                Spacer()
//                                Text(message.text)
//                                    .padding(10)
//                                    .background(Color.blue.opacity(0.3))
//                                    .foregroundColor(.black)
//                                    .cornerRadius(12)
//                            } else {
//                                Text(message.text)
//                                    .padding(10)
//                                    .background(Color.gray.opacity(0.5))
////                                    .foregroundColor(.black)
//                                    .cornerRadius(12)
//                                Spacer()
//                                
//                            }
//                        }
//                    }
//                }
//                .padding()
//            }
//
//            // Input field
//            HStack {
//                TextField("Type a message...", text: $chatVM.newMessage)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//
//                Button(action: {
//                    Task { await chatVM.sendMessage() }
//                }) {
//                    Image(systemName: "paperplane.fill")
//                        .foregroundColor(.blue)
//                }
//            }
//            .padding()
//        }
//        .navigationTitle("Chat")
//        .onAppear {
//            Task {
//                await chatVM.startConversation(
//                    listingId: listing.id,
//                    landlordId: listing.landlordId ?? ""
//                )
//            }
//        }
//    }
//}
