//
//  ConversationsViewModel.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-09-28.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class ConversationsViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    private let db = Firestore.firestore()
    
    func fetchMyConversations() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("conversations")
            .whereField("participants", arrayContains: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching conversations: \(error)")
                    return
                }
                
                self.conversations = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Conversation.self)
                } ?? []
            }
    }
}
