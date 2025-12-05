//
//  SecureRentalTests.swift
//  SecureRentalTests
//
//  Created by Haniya Akhtar on 2024-10-19.
//

import Testing
@testable import SecureRental
import Foundation

struct SecureRentalTests {

   
   
    @Test
    func testAppUserInitialization() {
        let user = AppUser(
            id: "u123",
            username: "testuser",
            email: "test@example.com",
            name: "Test User",
            profilePictureURL: "https://image.com/pic.png",
            rating: 4.7,
            reviews: ["Good", "Amazing"],
            favoriteListingIDs: ["listing1", "listing56"],
            isVerified: true
        )

        #expect(user.id == "u123")
        #expect(user.email == "test@example.com")
        #expect(user.name == "Test User")
        #expect(user.favoriteListingIDs.count == 2)
        #expect(user.isVerified == true)
        #expect(user.rating == 4.7)
    }

    @Test
    func testListingInitialization() {

        let listing = Listing(
            id: "123",
            title: "Test Apartment",
            description: "Nice place",
            price: "1200",
            imageURLs: ["img1"],
            location: "Toronto",
            isAvailable: true,
            numberOfBedrooms: 2,
            numberOfBathrooms: 1,
            squareFootage: 850,
            amenities: ["Wifi", "Parking"],
            street: "123 Main St",
            city: "Toronto",
            province: "Ontario",
            datePosted: Date(),
            landlordId: "abc",
            averageRating: 4.5,
            latitude: 43.6532,
            longitude: -79.3832
        )

        #expect(listing.title == "Test Apartment")
        #expect(listing.price == "1200")
        #expect(listing.numberOfBedrooms == 2)
        #expect(listing.isAvailable == true)
        #expect(listing.city == "Toronto")
    }
    func toggleFavoriteLocally(user: AppUser, listingId: String) -> [String] {
        var updated = user.favoriteListingIDs

        if let index = updated.firstIndex(of: listingId) {
            updated.remove(at: index)
        } else {
            updated.append(listingId)
        }

        return updated
    }

    @Test
    func testToggleFavoriteLogic() {

        var user = AppUser(
            username: "user",
            email: "user@mail.com",
            name: "User"
        )

        // FIRST TOGGLE → ADD
        user.favoriteListingIDs = toggleFavoriteLocally(user: user, listingId: "L1")
        #expect(user.favoriteListingIDs.contains("L1") == true)

        // SECOND TOGGLE → REMOVE
        user.favoriteListingIDs = toggleFavoriteLocally(user: user, listingId: "L1")
        #expect(user.favoriteListingIDs.contains("L1") == false)
    }

}
