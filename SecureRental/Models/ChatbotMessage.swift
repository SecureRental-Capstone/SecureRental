//
//  ChatbotMessage.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2025-09-28.
//


import SwiftUI

//Data model
struct QuickQuestion: Identifiable {
    let id = UUID()
    let icon: String
    let category: String
    let prompt: String
}


struct ChatbotMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp: Date
    let attachedListings: [Listing]? 
    
    init(text: String, isUser: Bool, timestamp: Date, attachedListings: [Listing]? = nil) {
            self.text = text
            self.isUser = isUser
            self.timestamp = timestamp
            self.attachedListings = attachedListings
        }
}
