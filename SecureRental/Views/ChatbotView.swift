import SwiftUI
import AWSCore
import AWSLex

struct ChatbotView: View {
    @State private var userInput: String = ""         // For capturing user input
    @State private var botResponse: String = ""       // For showing bot's response
    @State private var isSending: Bool = false        // To show a loading state when sending request
    @State private var chatMessages: [ChatMessage] = [] // Store chat messages
    @State private var keyboardHeight: CGFloat = 0    // Track the keyboard height

    var body: some View {
        VStack {
            // Header section with the title and profile pictures
            HStack {
                Image(systemName: "person.circle.fill") // Profile picture for bot (left)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.blue)
                    .padding(.leading)
                
                Text("Secure Rental Bot")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(action: {
                    // Action to close the chatbot and go back to the homepage
                }) {
                    Image(systemName: "xmark") // Close icon
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(.trailing)
                }

            }
            .padding()
            .background(Color.gray.opacity(0.1)) // Light background for the header

            // Chat messages display area
            ScrollView {
                VStack {
                    ForEach(chatMessages) { message in
                        HStack {
                            // Bot's message profile picture and message
                            if message.sender == .bot {
                                VStack(alignment: .leading) {
                                    
                                    HStack{
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.blue)
                                            .padding(.bottom, 5) // Adds space between the image and the message
                                        
                                        Text("Secure Rental").foregroundStyle(Color.gray).font(.system(size: 14))

                                    }//HSTACK
                                    Text(message.text)
                                        .padding()
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(10)
                                        .foregroundColor(.blue)
                                }
                                
                                Spacer()
                            }
                            // User's message profile picture and message
                            else {
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    
                                    Text(message.text)
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(10)
                                        .foregroundColor(.black)
                                    HStack{
                                        
                                        Text("You").foregroundStyle(Color.gray).font(.system(size: 14))
                                        
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.green)
                                            .padding(.top, 5) // Adds space between the message and the image
                                    }//Hstack
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, message.id == chatMessages.first?.id ? 10 : 5)

                    }
                }
            }
            
            Spacer() // Spacer added to push the text field and send button up

            // Input and send message at the bottom
            HStack {
                TextField("Ask the bot something", text: $userInput)
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.leading)
                
                Button(action: {
                    if !userInput.isEmpty {
                        sendTextToLex(text: userInput)
                    }
                }) {
                    Text(isSending ? "Sending..." : "Send")
                        .padding()
                        .frame(width: 80)
                        .background(isSending ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.trailing)
                }
                .disabled(isSending)
            }
            .padding(.bottom, keyboardHeight) // Move up when keyboard shows
            .animation(.easeOut(duration: 0.3), value: keyboardHeight) // Smooth transition
            .padding(.bottom, 20) // Add padding to prevent it from being too close to the bottom
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.bottom)
        .onTapGesture {
            // Dismiss the keyboard when tapping anywhere on the screen
            dismissKeyboard()
        }
        .onAppear {
            // Add observer for keyboard appearance and disappearance
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    self.keyboardHeight = keyboardFrame.height
                }
            }
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                self.keyboardHeight = 0
            }
        }
        .onDisappear {
            // Remove observers when the view disappears
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }

    // Function to send text to Lex bot
    func sendTextToLex(text: String) {
        isSending = true  // Disable button or UI while sending request
        
        // Add user message to chat
        chatMessages.append(ChatMessage(id: UUID(), text: text, sender: .user))

        // Prepare the request
        let request = AWSLexPostTextRequest()
        request?.inputText = text
        request?.botName = "SecureRentalV"  // Your bot's name (from AWS Lex)
        request?.botAlias = "$LATEST"  // Or another version alias of your bot
        request?.userId = "user123"  // Unique identifier for the user
        
        // Send the request to Lex using AWSLex's .text() method
        let lex = AWSLex.default()
        
        lex.postText(request!).continueWith { task -> Any? in
            if let error = task.error {
                DispatchQueue.main.async {
                    botResponse = "Error: \(error.localizedDescription)"
                    chatMessages.append(ChatMessage(id: UUID(), text: botResponse, sender: .bot))
                    isSending = false
                }
            } else if let result = task.result {
                DispatchQueue.main.async {
                    // Display Lex's response in the UI
                    let botReply = result.message ?? "No response from bot"
                    chatMessages.append(ChatMessage(id: UUID(), text: botReply, sender: .bot))
                    isSending = false  // Re-enable button after response
                }
            }
            return nil
        }
    }

    // Function to dismiss the keyboard
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ChatMessage: Identifiable {
    var id: UUID
    var text: String
    var sender: MessageSender
}

enum MessageSender {
    case user
    case bot
}
