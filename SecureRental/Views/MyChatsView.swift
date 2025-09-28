//
//  MyChatsView.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-09-28.
//

import SwiftUI

struct MyChatsView: View {
    @StateObject private var viewModel = ConversationsViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.conversations) { conversation in
//                NavigationLink(
////                    destination: ChatView(conversationId: conversation.id ?? "")
//                ) {
//                    VStack(alignment: .leading) {
//                        Text("Listing: \(conversation.listingId)")
//                            .font(.headline)
//                        Text("Chat with landlord/tenant")
//                            .font(.subheadline)
//                            .foregroundColor(.gray)
//                    }
//                }
            }
            .navigationTitle("My Chats")
            .onAppear {
                viewModel.fetchMyConversations()
            }
        }
    }
}
