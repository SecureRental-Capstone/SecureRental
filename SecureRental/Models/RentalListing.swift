//
//  RentalListing.swift
//  SecureRental
//
//  Created by Shehnazdeep Kaur on 2024-11-06.
//
//

import CoreLocation

struct RentalListing: Identifiable {
    let id = UUID()
    var title: String
    var description: String
    var price: String
    var imageName: String
    var location: String
    var isAvailable: Bool
    var datePosted: Date
    var numberOfBedrooms: Int
    var numberOfBathrooms: Int
    var squareFootage: Int
    var amenities: [String]
    var coordinates: CLLocationCoordinate2D // Add coordinates property
}

//       
//    static let sampleListings: [RentalListing] = [
//        RentalListing(
//            title: "Cozy Apartment",
//            description: "A charming one-bedroom apartment in the heart of downtown.",
//            price: "$1200/month",
//            imageName: "apartment1",
//            location: "Toronto, ON",
//            isAvailable: true,
//            datePosted: Date(),
//            numberOfBedrooms: 1,
//            numberOfBathrooms: 1,
//            squareFootage: 600,
//            amenities: ["WiFi", "Washer/Dryer", "Pet-friendly"]
//        ),
//        RentalListing(
//            title: "Luxury Condo",
//            description: "Spacious 2-bedroom, 2-bathroom condo with amazing city views.",
//            price: "$2500/month",
//            imageName: "condo1",
//            location: "Toronto, ON",
//            isAvailable: false,
//            datePosted: Date().addingTimeInterval(-3600), // Posted 1 hour ago
//            numberOfBedrooms: 2,
//            numberOfBathrooms: 2,
//            squareFootage: 1100,
//            amenities: ["Gym", "Parking", "Swimming Pool"]
//        ),
//        RentalListing(
//            title: "Charming Cottage",
//            description: "A lovely cottage by the lake with a peaceful view and large garden.",
//            price: "$1500/month",
//            imageName: "cottage1",
//            location: "Muskoka, ON",
//            isAvailable: true,
//            datePosted: Date().addingTimeInterval(-86400), // Posted 1 day ago
//            numberOfBedrooms: 3,
//            numberOfBathrooms: 2,
//            squareFootage: 1200,
//            amenities: ["Fireplace", "Private Garden", "Lake View"]
//        )
//    ]
//}
