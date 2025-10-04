//
//  Message.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-09-28.
//

import Foundation
import FirebaseFirestore

struct ChatMessage: Identifiable, Codable {
    @DocumentID var id: String?
    var senderId: String
    var text: String
    var timestamp: Date?
}
