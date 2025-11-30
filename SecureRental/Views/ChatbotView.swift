//
//  ChatbotView.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2025-09-28.
//
import SwiftUI

// MARK: - 4. Chatbot Header Component
struct ChatbotHeader: View {
    var body: some View {
        HStack {
            Image("chatbot2") // Use your specific app icon/asset here
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(.purple)
                .padding(8)
                .background(Color.purple.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text("SecureRental Bot")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("Always here to help")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
}

// MARK: - 5. Quick Question Card Component
struct QuestionCard: View {
    let question: QuickQuestion
    var action: (String) -> Void
    
    var body: some View {
        Button(action: { action(question.prompt) }) {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: question.icon)
                        .font(.title3)
                        .foregroundColor(.primary)
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(question.category)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    Text(question.prompt)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                }
            }
            .padding()
//            .frame(minHeight: 120, alignment: .topLeading)
            .frame(height: 140, alignment: .topLeading) // fixed height
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
// MARK: - 6. Quick Questions Container
struct QuickQuestionsView: View {
    let questions: [QuickQuestion]
    var action: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick questions to get started:")
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.leading, 4)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                ForEach(questions) { question in
                    QuestionCard(question: question, action: action)
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - 7. Message Bubbles
struct UserMessageBubble: View {
    let text: String
    var body: some View {
        Text(text)
            .padding(12)
            .background(Color.blue.opacity(0.8))
            .foregroundColor(.white)
            // FIXED CORNERS: Standard chat bubble uses a small/zero radius on the bottom-right corner
            // for the last bubble, but here we fix the inner corner:
            .cornerRadius(18, corners: [.topLeft, .topRight, .bottomLeft]) // Original corners
            .cornerRadius(4, corners: [.bottomLeft]) // Make the inner corner slightly sharper
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct AIMessageBubble: View {
    let text: String
    let timestamp: Date

    var body: some View {
        HStack(alignment: .top, spacing: 8) { // Alignment changed to .top
            // AI Icon
            Image("chatbot2")
                .resizable()
                .scaledToFit()
                .frame(width: 35, height: 35)
                .foregroundColor(.white)
//                .padding(3)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 0) { // Spacing set to 0 for tighter integration
                VStack(alignment: .leading, spacing: 4) { // Tighter spacing inside bubble
                    
                    //Main Content
                    Text(.init(text))
                        .font(.body)
                        .lineSpacing(4)      // space between lines
                        .multilineTextAlignment(.leading)
//                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(12) // Standard internal padding
                .background(Color.white)
                // Corner radius adjustment: Removed .topRight as the bubble is complex,
                // but kept the bottom corner adjustments.
                .cornerRadius(18, corners: [.allCorners])
                .cornerRadius(4, corners: [.topLeft]) // Slight adjustment to the very top corner near the icon
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                Text("SecureRental Bot • \(timestamp, style: .time)")
                    .font(.caption)
                    .fontWeight(.none)
                    .foregroundStyle(Color.gray)
                    .padding(.leading, 12) // same as bubble padding
                    .padding(.top, 3)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
            .offset(y: -4) // Slight upward lift to align the bubble top with the icon better
        }
//        .frame(maxWidth: UIScreen.main.bounds.width * 0.85, alignment: .leading)
    }
}

struct MessageBubbleView: View {
    let message: ChatbotMessage

    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                VStack(alignment: .trailing, spacing: 2){
                    UserMessageBubble(text: message.text)
                    Text("You • \(message.timestamp, style: .time)")
                        .font(.caption)
                        .fontWeight(.none)
                        .foregroundStyle(Color.gray)
//                        .padding(.leading, 12) // same as bubble padding
                        .padding(.top, 3)
                }
            } else {
                AIMessageBubble(text: message.text, timestamp: message.timestamp)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}


// MARK: - 8. Input Bar Component
struct InputBar: View {
    @Binding var inputText: String
    var sendAction: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                TextField("Ask me anything about housing...", text: $inputText)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                    .background(Color.white)
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                Button(action: sendAction) {
                                    Image(systemName: "paperplane.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.white) // Icon color should be white inside a colored circle
                                        .padding(8) // Padding around the icon inside the circle
                                        .background(inputText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray : Color.blue) // Circle background color
                                        .clipShape(Circle()) // Shape the background into a circle
                                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .padding(.top, 8)
            .background(Color.white)
        }
    }
}

struct TypingIndicator: View {
    @State private var dotCount = 0
    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 4) {
            Text("SecureRental Bot is typing")
                .font(.body)
                .foregroundColor(.gray)
            Text(String(repeating: ".", count: dotCount))
                .font(.caption)
                .foregroundColor(.gray)
                .frame(width: 12, alignment: .leading) // keeps width stable
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .onReceive(timer) { _ in
            dotCount = (dotCount + 1) % 4 // cycles 0 → 3 dots
        }
    }
}

// MARK: - 9. Main Chatbot View (The orchestrator)
struct ChatbotView: View {
    
    @EnvironmentObject var dbHelper: FireDBHelper
    @StateObject private var viewModel = ChatbotViewModel()
    @State private var inputText = ""

    private let quickQuestions: [QuickQuestion] = [
        QuickQuestion(icon: "house.fill", category: "Housing", prompt: "What documents do I need to rent?"),
        QuickQuestion(icon: "dollarsign.circle.fill", category: "Payments", prompt: "How does the security deposit work?"),
        QuickQuestion(icon: "mappin.and.ellipse", category: "Location", prompt: "Best areas for international students?"),
        QuickQuestion(icon: "graduationcap.fill", category: "Community", prompt: "Tips for finding roommates?"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            
            if let user = dbHelper.currentUser {
                
                // Header
                ChatbotHeader()

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 8) {

                            // Quick Questions
//                            if viewModel.messages.count <= 1 {
                                QuickQuestionsView(questions: quickQuestions) { prompt in
                                    self.inputText = prompt
                                    self.send()
                                }
                                .padding(.top, 10)
//                            }

                            // Chat Messages
                            ForEach(viewModel.messages) { message in
                                MessageBubbleView(message: message)
                                    .id(message.id) // important for scrollTo
                            }

                            // Typing Indicator
                            if viewModel.isLoading {
                                HStack {
                                    Image("chatbot2")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 35, height: 35)
                                        .clipShape(Circle())

                                    TypingIndicator()

                                    Spacer()
                                }
                                .padding(.horizontal)
                                .id("typingIndicator") // give it a fixed id
                                .transition(.opacity)
                                .padding(.bottom, 12) // Adds space between indicator and input bar
                            }
                        }
                        .padding(.bottom, 8)
                    }
                    .background(Color(.systemGroupedBackground))
                    // Scroll whenever messages change
                    .onChange(of: viewModel.messages.count) { _ in
                        DispatchQueue.main.async {
                            if let lastMessage = viewModel.messages.last {
                                withAnimation {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                    // Scroll to typing indicator when loading
                    .onChange(of: viewModel.isLoading) { _ in
                        DispatchQueue.main.async {
                            if viewModel.isLoading {
                                withAnimation {
                                    proxy.scrollTo("typingIndicator", anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                
                // Input Bar
                InputBar(inputText: $inputText, sendAction: send)
            }
        }
    }

    // MARK: - Send Action
    func send() {
        let trimmed = inputText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        viewModel.sendMessage(trimmed)
        inputText = ""
    }
}
