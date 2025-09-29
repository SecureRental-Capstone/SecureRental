//
//  MyChatsView.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-09-28.
//
//
//import SwiftUI
//
//struct MyChatsView: View {
//    @StateObject private var viewModel = ConversationsViewModel()
//    
//    var body: some View {
//        NavigationView {
//            List(viewModel.conversations) { conversation in
////                NavigationLink(
//////                    destination: ChatView(conversationId: conversation.id ?? "")
////                ) {
////                    VStack(alignment: .leading) {
////                        Text("Listing: \(conversation.listingId)")
////                            .font(.headline)
////                        Text("Chat with landlord/tenant")
////                            .font(.subheadline)
////                            .foregroundColor(.gray)
////                    }
////                }
//            }
//            .navigationTitle("My Chats")
//            .onAppear {
//                viewModel.fetchMyConversations()
//            }
//        }
//    }
//}
//
//  MyChatsView.swift
//  SecureRental
//
import SwiftUI
import FirebaseAuth

struct MyChatsView: View {
    @StateObject private var viewModel = ConversationsViewModel()
    
    var body: some View {
        NavigationView {
//            List(viewModel.conversations, id: \.id) { conversation in
//                let otherUserId = conversation.participants.first { $0 != Auth.auth().currentUser?.uid } ?? ""
//                let otherUserName = viewModel.userNames[otherUserId] ?? "Loading..."
//                
//                NavigationLink(
//                    destination: ChatView(listingId: conversation.listingId, conversationId: conversation.id ?? "", otherUserId: otherUserId)
//                ) {
//                    VStack(alignment: .leading) {
//                        Text("Listing: \(conversation.listingId)")
//                            .font(.headline)
//                        Text("Chat with: \(otherUserName)")
//                            .font(.subheadline)
//                            .foregroundColor(.gray)
//                    }
//                }
//            }
//            .navigationTitle("My Chats")
//            .onAppear {
//                viewModel.fetchMyConversations()
//            }
        }
    }
}
