//
//  ConversationsViewModel.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-09-28.
//


import FirebaseFirestore
import FirebaseAuth

class ConversationsViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?

    func listenForMyConversations(userId: String, completion: @escaping ([Conversation]) -> Void) {
        listener?.remove() // Remove previous listener if any

        listener = db.collection("conversations")
            .whereField("participants", arrayContains: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }

                let convs = documents.compactMap { doc -> Conversation? in
                    try? doc.data(as: Conversation.self)
                }

                completion(convs)
            }
    }

    deinit {
        listener?.remove()
    }
}

