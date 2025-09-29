//
//  ChatbotMessage.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2025-09-28.
//

import Foundation

struct ChatbotMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

