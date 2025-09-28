//
//  ChatViewModel.swift
//  SecureRental
//
//  Created by Anchal Sharma on 2025-09-21.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var newMessage: String = ""

    private var dbHelper = FireDBHelper.getInstance()

    private var listener: ListenerRegistration?
    private var conversationId: String?
    private let currentUserId = Auth.auth().currentUser?.uid ?? ""

    func startConversation(listingId: String, landlordId: String) async {
        do {
            let convId = try await dbHelper.startConversation(
                listingId: listingId,
                landlordId: landlordId,
                tenantId: currentUserId
            )
            self.conversationId = convId
            listenForMessages(conversationId: convId)
        } catch {
            print("❌ Failed to start conversation: \(error.localizedDescription)")
        }
    }

    func listenForMessages(conversationId: String) {
        listener?.remove()
        listener = dbHelper.listenForMessages(conversationId: conversationId) { [weak self] msgs in
            DispatchQueue.main.async {
                self?.messages = msgs
            }
        }
    }

    func sendMessage() async {
        guard let conversationId = conversationId, !newMessage.isEmpty else { return }
        do {
            try await dbHelper.sendMessage(conversationId: conversationId, senderId: currentUserId, text: newMessage)
            DispatchQueue.main.async {
                self.newMessage = ""
            }
        } catch {
            print("❌ Failed to send message: \(error.localizedDescription)")
        }
    }

    deinit {
        listener?.remove()
    }
}

//import Foundation
//import Amplify
//import Combine
//
//class ChatViewModel: ObservableObject {
//    @Published var messages: [Message] = []
//    @Published var newMessage: String = ""
//    
//    var listingID: String
//    private var subscription: AnyCancellable?
//    
//    init(listingID: String) {
//        self.listingID = listingID
//        fetchMessages()
//        subscribeToMessages()
//    }
//    
//    func fetchMessages() {
//        let predicate = Message.keys.listingID == listingID  // This works if `Message` is generated
//        Amplify.API.query(request: .list(Message.self, where: predicate)) { result in
//            switch result {
//            case .success(let messagesData):
//                DispatchQueue.main.async {
//                    self.messages = messagesData.items.sorted { $0.timestamp < $1.timestamp }
//                }
//            case .failure(let error):
//                print("Failed to fetch messages: \(error)")
//            }
//        }
//    }
//    
//    func sendMessage(senderID: String, receiverID: String) {
//        let message = Message(listingID: listingID, senderID: senderID, receiverID: receiverID, content: newMessage, timestamp: .now())
//        Amplify.API.mutate(request: .create(message)) { result in
//            switch result {
//            case .success(_):
//                DispatchQueue.main.async {
//                    self.newMessage = ""
//                }
//            case .failure(let error):
//                print("Failed to send message: \(error)")
//            }
//        }
//    }
//    
//    func subscribeToMessages() {
//        subscription = Amplify.API.subscribe(request: .subscription(of: Message.self, type: .onCreate)) { event in
//            switch event {
//            case .connection(let state):
//                print("Subscription connection: \(state)")
//            case .data(let result):
//                switch result {
//                case .success(let newMessage):
//                    if newMessage.listingID == self.listingID {
//                        DispatchQueue.main.async {
//                            self.messages.append(newMessage)
//                        }
//                    }
//                case .failure(let error):
//                    print("Subscription failed: \(error)")
//                }
//            case .failed(let error):
//                print("Subscription failed: \(String(describing: error))")
//            case .completed:
//                print("Subscription completed")
//            }
//        }
//    }
//}
//
////import Foundation
////import Amplify
////
////@MainActor
////class ChatViewModel: ObservableObject {
////    @Published var messages: [ChatMessage] = []
////    @Published var isLoading: Bool = false
////    
////    // Load messages for a given conversation from DynamoDB via API Gateway
////    func loadMessages(conversationId: String) async {
////        isLoading = true
////        defer { isLoading = false }
////        
////        let request = RESTRequest(path: "/getMessages?conversationId=\(conversationId)")
////        
////        do {
////            let data = try await Amplify.API.get(request: request)
////            let decoded = try JSONDecoder().decode([ChatMessage].self, from: data)
////            // Sort by timestamp
////            self.messages = decoded.sorted(by: { $0.timestamp < $1.timestamp })
////        } catch {
////            print("Failed to load messages: \(error)")
////            self.messages = []
////        }
////    }
////    
////    // Send a new message to DynamoDB
////    func sendMessage(conversationId: String,
////                     listingId: String,
////                     senderId: String,
////                     receiverId: String,
////                     text: String) async {
////        
////        let newMessage = ChatMessage(
////            id: UUID().uuidString,
////            conversationId: conversationId,
////            listingId: listingId,
////            senderId: senderId,
////            receiverId: receiverId,
////            text: text,
////            timestamp: Date(),
////            isRead: false
////        )
////        
////        guard let body = try? JSONEncoder().encode(newMessage) else {
////            print("Failed to encode message")
////            return
////        }
////        
////        let request = RESTRequest(path: "/sendMessage", body: body)
////        
////        do {
////            _ = try await Amplify.API.post(request: request)
////            // Optimistically update UI
////            self.messages.append(newMessage)
////            self.messages.sort(by: { $0.timestamp < $1.timestamp })
////        } catch {
////            print("Failed to send message: \(error)")
////        }
////    }
////}
