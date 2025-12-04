//
//  Rating.swift
//  SecureRental
//
//  Created by Shehnazdeep Kaur on 2025-10-07.
//

import Foundation
import FirebaseFirestore

struct Review: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var userName: String
    var rating: Double
    var comment: String
    var timestamp: Date
    var profilePictureURL: String?
    var isVerified: Bool? 

}
