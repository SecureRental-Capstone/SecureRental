//
//  Listing.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-09-23.
//

import Foundation

struct Listing: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var description: String
    var price: String
    var imageURLs: [String]
    var location: String
    var isAvailable: Bool
    var numberOfBedrooms: Int
    var numberOfBathrooms: Int
    var squareFootage: Int
    var amenities: [String]
    var street: String
    var city: String
    var province: String
    var comments: [String]? = []
    var ratings: [Double]? = []
    var datePosted: Date
    
    var landlordId: String       // creator (Auth.uid)
    var latitude: Double = 0.0
    var longitude: Double = 0.0
}

