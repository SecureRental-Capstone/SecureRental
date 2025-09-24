//
//  ChatMessage.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-09-21.
//

import Foundation

struct ChatMessage: Identifiable, Codable {
    let id: String
    let conversationId: String
    let listingId: String
    let senderId: String
    let receiverId: String
    let text: String
    let timestamp: Date
    var isRead: Bool
}

