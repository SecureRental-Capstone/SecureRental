//
//  Conversation.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-09-29.
//

import Foundation
import FirebaseFirestore


struct Conversation: Identifiable, Codable {
    @DocumentID var id: String?
    var listingId: String
    var participants: [String]
    var createdAt: Date?
    var lastMessageAt: Date?      // 👈 NEW
    var lastMessageText: String?  // optional
    var lastSenderId: String?     // optional
}
