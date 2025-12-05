//
//  ChatbotMessage.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2025-09-28.
//
import SwiftUI

//CHATBOT MODEL CLASSES

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

//OpenAI API Response Models
struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let role: String
        let content: String
    }
}

struct AnalyzerMessage: Codable {
    let role: String
    let content: String
}

struct ChatRequest: Codable {
    let model: String
    let messages: [AnalyzerMessage]
}

struct DiscrepancyResult: Codable {
    let discrepancy_detected: Bool?
    let details: String
}

struct SightEngResponse: Decodable {
    struct TypeInfo: Decodable {
        let ai_generated: Double
    }
    let status: String
    let type: TypeInfo
}

struct ListingAnalysisResult {
    let discrepancy: DiscrepancyResult
    let aiImageScores: [Double] // 0.0–1.0
}
