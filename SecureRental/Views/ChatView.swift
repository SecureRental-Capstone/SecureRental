//
//  ChatView.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-09-21.
//
//

//import SwiftUI
//import FirebaseAuth
//struct ChatView: View {
//    @StateObject var chatVM = ChatViewModel()
//    var conversationId: String
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
//                                    .background(Color.blue.opacity(0.8))
//                                    .foregroundColor(.white)
//                                    .cornerRadius(12)
//                            } else {
//                                Text(message.text)
//                                    .padding(10)
//                                    .background(Color.gray.opacity(0.3))
//                                    .foregroundColor(.black)
//                                    .cornerRadius(12)
//                                Spacer()
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
//                    Task { await chatVM.sendMessage(conversationId: conversationId) }
//                }) {
//                    Image(systemName: "paperplane.fill")
//                        .foregroundColor(.blue)
//                }
//            }
//            .padding()
//        }
//        .navigationTitle("Chat")
//        .onAppear {
//            chatVM.listenForMessages(conversationId: conversationId)
//        }
//    }
//}

import SwiftUI
import FirebaseAuth

struct ChatView: View {
    @StateObject var chatVM = ChatViewModel()
    var listing: Listing

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
                                    .background(Color.blue.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            } else {
                                Text(message.text)
                                    .padding(10)
                                    .background(Color.gray.opacity(0.3))
                                    .foregroundColor(.black)
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
                await chatVM.startConversation(listingId: listing.id, landlordId: listing.landlordId ?? "")
            }
        }
    }
}
//
//struct ChatView: View {
//    @ObservedObject var viewModel: ChatViewModel
//    var senderID: String
//    var receiverID: String
//
//    var body: some View {
//        VStack {
//            ScrollView {
//                ForEach(viewModel.messages, id: \.id) { msg in
//                    HStack {
//                        if msg.senderID == senderID {
//                            Spacer()
//                            Text(msg.content)
//                                .padding()
//                                .background(Color.blue)
//                                .foregroundColor(.white)
//                                .cornerRadius(10)
//                        } else {
//                            Text(msg.content)
//                                .padding()
//                                .background(Color.gray.opacity(0.3))
//                                .cornerRadius(10)
//                            Spacer()
//                        }
//                    }.padding(.horizontal)
//                }
//            }
//            
//            HStack {
//                TextField("Type a message...", text: $viewModel.newMessage)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                Button("Send") {
//                    viewModel.sendMessage(senderID: senderID, receiverID: receiverID)
//                }
//                .disabled(viewModel.newMessage.isEmpty)
//            }
//            .padding()
//        }
//        .navigationTitle("Chat with Landlord")
//    }
//}

////import SwiftUI
////
////struct ChatView: View {
////    @StateObject var viewModel = ChatViewModel()
////    @State private var messageText = ""
////    
////    let conversationId: String
////    let listingId: String
////    let senderId: String
////    let receiverId: String
////    
////    var body: some View {
////        VStack {
////            ScrollView {
////                ForEach(viewModel.messages) { message in
////                    HStack {
////                        if message.senderId == senderId {
////                            Spacer()
////                            Text(message.text)
////                                .padding()
////                                .background(Color.blue.opacity(0.8))
////                                .cornerRadius(12)
////                                .foregroundColor(.white)
////                                .frame(maxWidth: 250, alignment: .trailing)
////                        } else {
////                            Text(message.text)
////                                .padding()
////                                .background(Color.gray.opacity(0.3))
////                                .cornerRadius(12)
////                                .frame(maxWidth: 250, alignment: .leading)
////                            Spacer()
////                        }
////                    }
////                    .padding(.horizontal)
////                    .padding(.vertical, 4)
////                }
////            }
////            
////            HStack {
////                TextField("Type a message...", text: $messageText)
////                    .textFieldStyle(RoundedBorderTextFieldStyle())
////                
////                Button("Send") {
////                    Task {
////                        await viewModel.sendMessage(
////                            conversationId: conversationId,
////                            listingId: listingId,
////                            senderId: senderId,
////                            receiverId: receiverId,
////                            text: messageText
////                        )
////                        messageText = ""
////                    }
////                }
////                .padding(.leading, 8)
////            }
////            .padding()
////        }
////        .navigationTitle("Chat")
////        .onAppear {
////            Task {
////                await viewModel.loadMessages(conversationId: conversationId)
////            }
////        }
////    }
////}
