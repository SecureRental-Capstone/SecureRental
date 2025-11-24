//
//  Rating.swift
//  SecureRental
//
//  Created by Shehnazdeep Kaur on 2025-10-07.
//

import Foundation
import FirebaseFirestore

struct Review: Codable, Identifiable {
    @DocumentID var id: String?  // Firestore will auto-generate this
    var userId: String
    var userName: String
    var rating: Double
    var comment: String
    var timestamp: Date
    var isVerified: Bool
}
