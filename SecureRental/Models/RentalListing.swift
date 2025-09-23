//
//  RentalListing.swift
//  SecureRental
//
//  Created by Anchal Sharma on 2024-11-06.
//
//

import Foundation
import CoreLocation
import UIKit

struct RentalListing: Identifiable {
    let id = UUID()
    var title: String
    var description: String
    var price: String
    var images: [UIImage]  // Store the image data
    var location: String
    var isAvailable: Bool
    var datePosted: Date
    var numberOfBedrooms: Int
    var numberOfBathrooms: Int
    var squareFootage: Int
    var amenities: [String]    // List of amenities including selected and custom
    var street: String
    var city: String
    var province: String
    var comments: [String]? = []
    var ratings: [Double]? = []
    var isFavourite: Bool = false
}

