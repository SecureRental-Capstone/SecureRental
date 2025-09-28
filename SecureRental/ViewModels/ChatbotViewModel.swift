//
//  ChatbotViewModel.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2025-09-28.
//

import Foundation
import Combine

class ChatbotViewModel: ObservableObject {
    @Published var messages: [ChatbotMessage] = []
    @Published var isLoading = false

    private var cancellables = Set<AnyCancellable>()
    //will replace to obscure key (this is test key)
    private let apiKey = "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"
    private let apiURL = URL(string: "https://api.openai.com/v1/chat/completions")!

    func sendMessage(_ text: String) {
        let userMessage = ChatbotMessage(text: text, isUser: true)
        messages.append(userMessage)
        isLoading = true

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant that answers questions about the rental app."],
                ["role": "user", "content": text]
            ]
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            print("Error: Failed to encode JSON body")
            return
        }

        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: OpenAIResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                if case .failure(let error) = completion {
                    print("OpenAI API error: \(error)")
                }
            }, receiveValue: { response in
                if let reply = response.choices.first?.message.content {
                    let botMessage = ChatbotMessage(text: reply, isUser: false)
                    self.messages.append(botMessage)
                }
                self.isLoading = false
            })
            .store(in: &cancellables)
    }
}

struct OpenAIResponse: Codable {
    let choices: [Choice]
    struct Choice: Codable { let message: Message }
    struct Message: Codable { let role: String; let content: String }
}
