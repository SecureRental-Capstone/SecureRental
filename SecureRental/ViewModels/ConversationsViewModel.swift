//
//  ConversationsViewModel.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-09-28.
//

import FirebaseFirestore
import FirebaseAuth

@MainActor
class ConversationsViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private let dbHelper = FireDBHelper.getInstance()

    // Real-time listener for user conversations
    func listenForMyConversations(userId: String, completion: @escaping ([Conversation]) -> Void) {
        listener?.remove()
        listener = db.collection("conversations")
            .whereField("participants", arrayContains: userId)
//            .order(by: "lastMessageAt", descending: true)   // 👈 important
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                let convs = documents.compactMap { doc -> Conversation? in
                    try? doc.data(as: Conversation.self)
                }
                completion(convs)
            }
    }

    // Convenience: fetch last message for a conversation
    func fetchLastMessage(conversationId: String) async -> ChatMessage? {
        do {
            return try await dbHelper.fetchLastMessage(for: conversationId)
        } catch {
            print("❌ Failed to fetch last message: \(error.localizedDescription)")
            return nil
        }
    }

    deinit {
        listener?.remove()
    }
}

