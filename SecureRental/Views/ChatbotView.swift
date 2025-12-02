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
//            .background(Color.blue.opacity(0.8))
            .background(Color.primaryPurple)
            .foregroundColor(.white)
            // FIXED CORNERS: Standard chat bubble uses a small/zero radius on the bottom-right corner
            // for the last bubble, but here we fix the inner corner:
            .cornerRadius(18, corners: [.topLeft, .topRight, .bottomLeft]) // Original corners
            .cornerRadius(4, corners: [.bottomLeft]) // Make the inner corner slightly sharper
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct AIMessageBubble: View {
    
    let rvm = RentalListingsViewModel()
    let message: ChatbotMessage // Changed to accept the full message object
    let dbHelper = FireDBHelper.getInstance()
    @EnvironmentObject var currencyManager: CurrencyViewModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // AI Icon
            Image("chatbot2")
                .resizable()
                .scaledToFit()
                .frame(width: 35, height: 35)
                .foregroundColor(.white)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    
                    // Main Content (Text)
                    Text(.init(message.text))
                        .font(.body)
                        .lineSpacing(4)
                        .multilineTextAlignment(.leading)

                    // 👇 NEW: Conditional Rendering of Attached Listings
                    if let listings = message.attachedListings, !listings.isEmpty {
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        // Display the list of results
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(listings) { listing in
                                // Use the new card component
                                NavigationLink {
                                    RentalListingDetailView(listing: listing).environmentObject(currencyManager)
                                        .environmentObject(dbHelper)
                                } label: {
                                    //RentalListingCardView(listing: listing, vm: currencyManager).environmentObject(rvm)
                                    AIListingCardView(listing: listing).environmentObject(rvm).environmentObject(currencyManager)
                                }
                            }
                        }
                    }
                }
                .padding(12) // Standard internal padding
                .background(Color.white)
                .cornerRadius(18, corners: [.allCorners])
                .cornerRadius(4, corners: [.topLeft])
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                
                Text("SecureRental Bot • \(message.timestamp, style: .time)")
                    .font(.caption)
                    .fontWeight(.none)
                    .foregroundStyle(Color.gray)
                    .padding(.leading, 12)
                    .padding(.top, 3)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
            .offset(y: -4)
        }
    }
}

struct AIListingCardView: View {
    let listing: Listing
    @EnvironmentObject var vm: CurrencyViewModel
    @EnvironmentObject var rvm: RentalListingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) { // spacing: 0 for edge-to-edge look
            
            // 1. Constrained Image Placeholder (Edge-to-edge top)
            ZStack(alignment: .topTrailing) {
                // Placeholder for the actual property photo
                AsyncImage(url: URL(string: listing.imageURLs.first ?? "")) { image in
                    image.resizable().scaledToFill()
                        .frame(height: 140) // KEY FIX: Limit the image height to prevent zoom effect
                        .clipped()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                } placeholder: {
                    Color(.systemGray4)
                }
                // Favorite Heart icon (using the one from the screenshot)
                Button {
                    withAnimation(.spring()) {
                        rvm.toggleFavorite(for: listing) // listing is the item you want to favorite
                    }
                } label: {
                    Image(systemName: rvm.isFavorite(listing) ? "heart.fill" : "heart")
                        .padding(6)
                    //.background(Color.black.opacity(0.3))
                        .background(Color.white)
                        .clipShape(Circle())
                        .padding(8)
                        .foregroundColor(rvm.isFavorite(listing) ? .red : .gray)
                }
            }
            .frame(maxWidth: .infinity)

                // 2. Details (Padded section below the image)
                VStack(alignment: .leading, spacing: 8) {
                    
                    // Title and Price (Top line)
                    HStack(alignment: .lastTextBaseline) {
                        Text(listing.title)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(vm.convertedPrice(basePriceString: listing.price) + "/mo")
                            .font(.subheadline)
                            .fontWeight(.heavy)
                            .foregroundColor(.green)
                    }
                    
                    // Location Text
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(listing.location)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    
                    // Bed/Bath/Details Bar
                    HStack(spacing: 12) {
                        Group {
                            HStack(spacing: 4) {
                                Image(systemName: "bed.double.fill")
                                Text("\(listing.numberOfBedrooms) bed")
                            }
                            
                            // Separate amenities with a divider
                            Divider()
                                .frame(height: 12)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "bathtub.fill")
                                Text("\(listing.numberOfBathrooms) bath")
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
                .padding(12) // Add padding to the detail section
            }
            .background(Color.white)
            // Apply corner radius only to the whole card
            .cornerRadius(12)
            // Use shadow instead of a border for a sleeker look
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }

struct MessageBubbleView: View {
    let message: ChatbotMessage
    @EnvironmentObject var currencyManager: CurrencyViewModel

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
                //AIMessageBubble(text: message.text, timestamp: message.timestamp)
                AIMessageBubble(message: message).environmentObject(currencyManager)
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
    
    @FocusState.Binding var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                TextField("Ask me anything about housing...", text: $inputText)
                    .focused($isFocused) // Apply focus tracking
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                    .background(Color.white)
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(isFocused ? Color.blue : Color.gray.opacity(0.3), lineWidth: isFocused ? 2 : 1)
//                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
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
    @FocusState private var isTextFieldFocused: Bool
    @EnvironmentObject var currencyManager: CurrencyViewModel

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
                                MessageBubbleView(message: message).environmentObject(currencyManager)
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
                    .onTapGesture {
                        isTextFieldFocused = false
                    }
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
                InputBar(inputText: $inputText, sendAction: send, isFocused: $isTextFieldFocused)
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
