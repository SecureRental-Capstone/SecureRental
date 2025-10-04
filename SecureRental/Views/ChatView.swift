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
//    var listingId: String
//    var conversationId: String
//    var otherUserId: String


    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(chatVM.messages) { message in
                        HStack {
                            if message.senderId == Auth.auth().currentUser?.uid {
                                Spacer()
                                Text(message.text)
                                    .padding(10)
                                    .background(Color.blue.opacity(0.3))
                                    .foregroundColor(.black)
                                    .cornerRadius(12)
                            } else {
                                Text(message.text)
                                    .padding(10)
                                    .background(Color.gray.opacity(0.5))
//                                    .foregroundColor(.black)
                                    .cornerRadius(12)
                                Spacer()
                                
                            }
                        }
                    }
                }
                .padding()
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
                    landlordId: listing.landlordId ?? ""
                )
            }
        }
    }
}
