//
//  ChatbotViewModel.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2024-12-06.
//

import SwiftUI

class ChatbotViewModel: ObservableObject {
    @Published var userInput: String = ""            // User input
    @Published var botResponse: String = ""          // Bot's response
    @Published var isSending: Bool = false           // Loading state
    @Published var chatMessages: [ChatMessage] = []  // Chat messages array
    @Published var keyboardHeight: CGFloat = 0       // Keyboard height

    private let chatService = ChatService()          // The service that communicates with Lex

    // Function to send user input to the bot
    func sendTextToBot() {
        guard !userInput.isEmpty else { return }
        
        // Add user message to chat
        chatMessages.append(ChatMessage(id: UUID(), text: userInput, sender: .user))
        isSending = true

        // Call the service to send message to Lex
        chatService.sendMessageToBot(message: userInput) { [weak self] response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.botResponse = "Error: \(error.localizedDescription)"
                    self?.chatMessages.append(ChatMessage(id: UUID(), text: self?.botResponse ?? "Error", sender: .bot))
                } else if let response = response {
                    self?.chatMessages.append(ChatMessage(id: UUID(), text: response, sender: .bot))
                }
                self?.isSending = false
            }
        }
        
        // Clear user input
        userInput = ""
    }

    // Function to dismiss the keyboard
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    // Function to listen for keyboard notifications
    func addKeyboardListeners() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                self?.keyboardHeight = keyboardFrame.height
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] _ in
            self?.keyboardHeight = 0
        }
    }
    
    // Remove observers when view disappears
    func removeKeyboardListeners() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
