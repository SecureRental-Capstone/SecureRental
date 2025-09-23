//
//  User.swift
//  SecureRental
//
//  Created by Shehnazdeep Kaur on 2024-11-06.
//

import Foundation
import SwiftUI

    // Define the User class
class User: Identifiable, ObservableObject {
        // Unique ID for the user (can be used for fetching from databases, etc.)
    var id = UUID()
    
    var username: String
    var password: String
    
        // Required user information
    @Published var name: String?
    @Published var email: String?
    @Published var profilePicture: Image?
    
        // Optional user information
    @Published var phoneNumber: String?
    @Published var address: String?
    @Published var bio: String?
    @Published var rating: Double?
        // Initializer for the User class
    init(name: String, email: String, profilePicture: Image? = nil, phoneNumber: String? = nil, address: String? = nil, bio: String? = nil, username: String, password: String) {
        self.name = name
        self.email = email
        self.profilePicture = profilePicture
        self.phoneNumber = phoneNumber
        self.address = address
        self.bio = bio
        self.username = username
        self.password = password
    }
        // Sample static data for the User class
    static let sampleUser = User(name: "Will Smith", email: "wsmith@example.com", profilePicture: Image(systemName: "person.circle"), phoneNumber: "123-456-7890", address: "123 Main Street, Toronto, ON", bio: "Passionate about technology and coding.", username: "testing", password: "testing")

}



