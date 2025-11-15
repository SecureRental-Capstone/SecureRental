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
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let now = Date()

        let msg = ChatMessage(
            id: nil,
            senderId: uid,
            text: text,
            timestamp: now
        )

        do {
            // add message
            _ = try db.collection("conversations")
                .document(conversationId)
                .collection("messages")
                .addDocument(from: msg)

            // update parent doc
            try await db.collection("conversations")
                .document(conversationId)
                .updateData([
                    "lastMessage": text,
                    "lastMessageAt": now
                ])

        } catch {
            print("❌ send failed: \(error)")
        }
    }


    deinit {
        listener?.remove()
    }
}
