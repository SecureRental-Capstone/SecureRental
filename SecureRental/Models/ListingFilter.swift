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
    var bedrooms: Int? // For exact bedroom match
    var bathrooms: Int? // For exact bathroom match
    var location: String? // Location name (user input)
    var latitude: Double? // Latitude for location-based filtering
    var longitude: Double? // Longitude for location-based filtering

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


