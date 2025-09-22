//
//  Listing.swift
//  SecureRental
//
//  Created by Shehnazdeep Kaur on 2024-12-06.
//

import Foundation
import CoreLocation
import UIKit

struct Listing: Identifiable {
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
    var owner: String
}

extension Listing {
    func toRentalListing(withImageKeys keys: [String], owner: String? = nil) -> RentalListing {
        return RentalListing(
            title: self.title,
            description: self.description,
            price: self.price,
            images: keys, // use S3 keys instead of UIImage
            location: self.location,
            isAvailable: self.isAvailable,
            datePosted: .now(),
            numberOfBedrooms: self.numberOfBedrooms,
            numberOfBathrooms: self.numberOfBathrooms,
            squareFootage: self.squareFootage,
            amenities: self.amenities,
            owner: self.owner
        )
    }
}
