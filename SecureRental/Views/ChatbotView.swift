import SwiftUI

struct ChatbotView: View {
    @StateObject private var viewModel = ChatbotViewModel()  // ViewModel to handle the logic

    var body: some View {
        VStack {
            // Header section
            HStack {
                Image(systemName: "person.circle.fill")
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
                    // Close the chatbot and return to homepage
                }) {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(.trailing)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            
            // Chat messages
            ScrollView {
                VStack {
                    ForEach(viewModel.chatMessages) { message in
                        HStack {
                            // Bot's message
                            if message.sender == .bot {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.blue)
                                            .padding(.bottom, 5)
                                        Text("Secure Rental")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                    Text(message.text)
                                        .padding()
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(10)
                                        .foregroundColor(.blue)
                                }
                                Spacer()
                            }
                            // User's message
                            else {
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text(message.text)
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(10)
                                        .foregroundColor(.black)
                                    HStack {
                                        Text("You")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.green)
                                            .padding(.top, 5)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, message.id == viewModel.chatMessages.first?.id ? 10 : 5)
                    }
                }
            }
            
            Spacer()

            // Text input and send button
            HStack {
                TextField("Ask the bot something", text: $viewModel.userInput)
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.leading)
                
                Button(action: {
                    viewModel.sendTextToBot()
                }) {
                    Text(viewModel.isSending ? "Sending..." : "Send")
                        .padding()
                        .frame(width: 80)
                        .background(viewModel.isSending ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.trailing)
                }
                .disabled(viewModel.isSending)
            }
            .padding(.bottom, viewModel.keyboardHeight)
            .animation(.easeOut(duration: 0.3), value: viewModel.keyboardHeight)
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.bottom)
        .onTapGesture {
            viewModel.dismissKeyboard()
        }
        .onAppear {
            viewModel.addKeyboardListeners()
        }
        .onDisappear {
            viewModel.removeKeyboardListeners()
        }
    }
}
