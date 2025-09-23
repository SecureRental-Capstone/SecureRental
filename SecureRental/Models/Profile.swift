//
//  Profile.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2024-11-15.
//
import Foundation

struct Profile {
    var userId: String
    var email: String?
    var name: String?
    var bio: String?
    var address: String?
    var phoneNumber: String?
    var age: Int?

    //this init allows creating a Profile from individual properties
    init(userId: String, email: String? = nil, name: String? = nil, bio: String? = nil, address: String? = nil, phoneNumber: String? = nil, age: Int? = nil) {
        self.userId = userId
        self.email = email
        self.name = name
        self.bio = bio
        self.address = address
        self.phoneNumber = phoneNumber
        self.age = age
    }
}


