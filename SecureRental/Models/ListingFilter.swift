//
//  ListingFilter.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2025-12-01.
//
import Foundation

// ListingFilter Model
struct ListingFilter {
    var minPrice: Double?
    var maxPrice: Double?
    var bedrooms: Int?
    var bathrooms: Int?
    var location: String?
    var latitude: Double?
    var longitude: Double? 

    init(minPrice: Double? = nil, maxPrice: Double? = nil, bedrooms: Int? = nil, bathrooms: Int? = nil, location: String? = nil, latitude: Double? = nil, longitude: Double? = nil) {
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        self.bedrooms = bedrooms
        self.bathrooms = bathrooms
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
    }
}


