//
//  Conversation.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-09-29.
//

import Foundation
import FirebaseFirestore


struct Conversation: Identifiable, Codable {
    @DocumentID var id: String?
    var participants: [String]
    var listingId: String
    var createdAt: Date?
}
