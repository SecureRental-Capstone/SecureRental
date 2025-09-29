//
//  ConversationsViewModel.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-09-28.
//
//
//import Foundation
//import FirebaseAuth
//import FirebaseFirestore
//
//class ConversationsViewModel: ObservableObject {
//    @Published var conversations: [Conversation] = []
//    private let db = Firestore.firestore()
//    
//    func fetchMyConversations() {
//        guard let userId = Auth.auth().currentUser?.uid else { return }
//        
//        db.collection("conversations")
//            .whereField("participants", arrayContains: userId)
//            .order(by: "createdAt", descending: true)
//            .addSnapshotListener { snapshot, error in
//                if let error = error {
//                    print("Error fetching conversations: \(error)")
//                    return
//                }
//                
//                self.conversations = snapshot?.documents.compactMap { doc in
//                    try? doc.data(as: Conversation.self)
//                } ?? []
//            }
//    }
//}

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class ConversationsViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var userNames: [String: String] = [:] // Store userId -> name
    
    private let db = Firestore.firestore()
    
    func fetchMyConversations() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("conversations")
            .whereField("participants", arrayContains: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching conversations: \(error)")
                    return
                }
                
                self.conversations = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Conversation.self)
                } ?? []
                
                // Fetch names for all other participants
                for conversation in self.conversations {
                    for participantId in conversation.participants {
                        if participantId != userId && self.userNames[participantId] == nil {
                            self.fetchUserName(userId: participantId)
                        }
                    }
                }
            }
    }
    
    private func fetchUserName(userId: String) {
        db.collection("Users").document(userId).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            if let data = snapshot?.data(), let name = data["name"] as? String {
                DispatchQueue.main.async {
                    self.userNames[userId] = name
                }
            }
        }
    }
}
