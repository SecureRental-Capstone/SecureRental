//
//  ChatbotView.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2025-09-28.
//

import SwiftUI

struct ChatbotView: View {
    @StateObject private var viewModel = ChatbotViewModel()
    @State private var inputText = ""

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    ForEach(viewModel.messages) { message in
                        HStack {
                            if message.isUser {
                                Spacer()
                                Text(message.text)
                                    .padding()
                                    .background(Color.blue.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            } else {
                                Text(message.text)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(12)
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                    }
                }

                if viewModel.isLoading {
                    ProgressView("Thinking...")
                        .padding()
                }

                HStack {
                    TextField("Ask about the app...", text: $inputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: send) { Text("Send") }
                        .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding()
            }
            .navigationTitle("Chatbot")
        }
    }

    func send() {
        let trimmed = inputText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        viewModel.sendMessage(trimmed)
        inputText = ""
    }
}

struct ChatbotView_Previews: PreviewProvider {
    static var previews: some View {
        ChatbotView()
    }
}
