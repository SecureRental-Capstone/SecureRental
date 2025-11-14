//
//  ChatViewModel.swift
//  SecureRental
//
//  Created by Anchal Sharma on 2025-09-21.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var newMessage: String = ""

    private var listener: ListenerRegistration?
    private let db = Firestore.firestore()

    func listenToMessages(conversationId: String) async {
        listener?.remove()
        listener = db.collection("conversations")
            .document(conversationId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let docs = snapshot?.documents else { return }
                self.messages = docs.compactMap { try? $0.data(as: ChatMessage.self) }
            }
    }

    func sendMessage(to conversationId: String, text: String) async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let convRef = db.collection("conversations").document(conversationId)

        do {
            // 1) add message
            let messageData: [String: Any] = [
                "text": text,
                "senderId": currentUserId,
                "timestamp": FieldValue.serverTimestamp()
            ]

            try await convRef.collection("messages").addDocument(data: messageData)

            // 2) update conversation metadata
            try await convRef.updateData([
                "lastMessageAt": FieldValue.serverTimestamp(),
                "lastMessageText": text,
                "lastSenderId": currentUserId
            ])

        } catch {
            print("❌ Failed to send message: \(error)")
        }
    }


    deinit {
        listener?.remove()
    }
}
