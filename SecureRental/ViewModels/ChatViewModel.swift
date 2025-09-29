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

    private var dbHelper = FireDBHelper.getInstance()

    private var listener: ListenerRegistration?
    private var conversationId: String?
    private let currentUserId = Auth.auth().currentUser?.uid ?? ""

    func startConversation(listingId: String, landlordId: String) async {
        do {
            let convId = try await dbHelper.startConversation(
                listingId: listingId,
                landlordId: landlordId,
                tenantId: currentUserId
            )
            self.conversationId = convId
            listenForMessages(conversationId: convId)
        } catch {
            print("❌ Failed to start conversation: \(error.localizedDescription)")
        }
    }

    func listenForMessages(conversationId: String) {
        listener?.remove()
        listener = dbHelper.listenForMessages(conversationId: conversationId) { [weak self] msgs in
            DispatchQueue.main.async {
                self?.messages = msgs
            }
        }
    }

    func sendMessage() async {
        guard let conversationId = conversationId, !newMessage.isEmpty else { return }
        do {
            try await dbHelper.sendMessage(conversationId: conversationId, senderId: currentUserId, text: newMessage)
            DispatchQueue.main.async {
                self.newMessage = ""
            }
        } catch {
            print("❌ Failed to send message: \(error.localizedDescription)")
        }
    }

    deinit {
        listener?.remove()
    }
}
