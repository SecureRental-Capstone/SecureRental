//
//  ChatbotViewModel.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2025-09-28.

import SwiftUI
import Combine

// MARK: - Chatbot ViewModel using OpenAI API
class ChatbotViewModel: ObservableObject {
    @Published var messages: [ChatbotMessage] = [
        // Initial AI welcome message
        ChatbotMessage(
            text: "I'm here to help international students navigate housing in the US. Ask me anything about renting apartments, required documents, finding roommates, or understanding the rental process!",
            isUser: false,
            timestamp: Date(timeIntervalSinceNow: -60 * 5)
        )
    ]
    @Published var isLoading: Bool = false

    private var cancellables = Set<AnyCancellable>()
    
    // TODO: Replace with your real OpenAI API key securely
    private let apiKey = "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"
    private let apiURL = URL(string: "https://api.openai.com/v1/chat/completions")!

    // MARK: - Send a user message and get AI response
    func sendMessage(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        // 1️⃣ Append user message
        let userMessage = ChatbotMessage(text: text, isUser: true, timestamp: Date())
        messages.append(userMessage)
        isLoading = true

        // 2️⃣ Prepare request body
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": """
                    You are a helpful assistant that answers questions about the rental app. Only answer questions about the app or rental-related queries, not unrelated topics.
                    The app has a login page, signup flow with ID verification, home page with rental listings, bottom nav with Home, Messages, Favourites, Profile, chat bubble for this bot, search/add listing buttons, and listing management features.
                    """],
                ["role": "user", "content": text]
            ]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            print("Error: Failed to encode JSON body")
            isLoading = false
            return
        }
        
        // 3️⃣ Build request
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // 4️⃣ Send request
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: OpenAIResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("OpenAI API error: \(error)")
                    // Optional: Append an error message to the chat
                    self?.messages.append(ChatbotMessage(
                        text: "Sorry, I couldn't get a response. Please try again.",
                        isUser: false,
                        timestamp: Date()
                    ))
                }
            }, receiveValue: { [weak self] response in
                if let reply = response.choices.first?.message.content {
                    let botMessage = ChatbotMessage(text: reply, isUser: false, timestamp: Date())
                    self?.messages.append(botMessage)
                }
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }
}

// MARK: - OpenAI API Response Models
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
