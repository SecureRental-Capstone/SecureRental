//
//  ChatbotMessage.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2025-09-28.
//

//import Foundation
//
//struct ChatbotMessage: Identifiable {
//    let id = UUID()
//    let text: String
//    let isUser: Bool
//}
import SwiftUI

// MARK: - 1. Data Model for Quick Questions
struct QuickQuestion: Identifiable {
    let id = UUID()
    let icon: String
    let category: String
    let prompt: String
}

// NOTE: You must define your ChatMessage model here or ensure it's available.
// Assuming a simple model like this:
struct ChatbotMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool // true for user, false for AI
    let timestamp: Date
    let attachedListings: [Listing]? // Has default value
    
    init(text: String, isUser: Bool, timestamp: Date, attachedListings: [Listing]? = nil) {
            self.text = text
            self.isUser = isUser
            self.timestamp = timestamp
            self.attachedListings = attachedListings
        }
}
