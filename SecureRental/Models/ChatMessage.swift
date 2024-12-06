//
//  ChatMessage.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2024-12-06.
//
import Foundation

// Enum for sender (user or bot)
enum MessageSender {
    case user
    case bot
}

// Struct to represent each chat message
struct ChatMessage: Identifiable {
    var id: UUID
    var text: String
    var sender: MessageSender
}

