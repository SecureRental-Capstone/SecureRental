////
////  ChatView.swift
////  SecureRental
////
////  Created by Anchal  Sharma  on 2025-09-21.
////
//
//import SwiftUI
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
//
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
