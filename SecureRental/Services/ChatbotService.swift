//
//  ChatbotService.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2024-12-06.
//
import Foundation
import AWSLex

class ChatService {
    // Function to send a message to the Lex bot and return the response
    func sendMessageToBot(message: String, completion: @escaping (String?, Error?) -> Void) {
        let request = AWSLexPostTextRequest()
        request?.inputText = message
        request?.botName = "SecureRentalV"  // Your bot's name
        request?.botAlias = "$LATEST"      // Or another version alias of your bot
        request?.userId = "user123"        // Unique identifier for the user
        
        let lex = AWSLex.default()
        
        lex.postText(request!).continueWith { task -> Any? in
            if let error = task.error {
                completion(nil, error)
            } else if let result = task.result {
                completion(result.message, nil)
            }
            return nil
        }
    }
}

