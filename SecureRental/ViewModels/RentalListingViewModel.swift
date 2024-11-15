//
//  RentalListingViewModel.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2024-11-07.
//

//
//  RentalListingViewModel.swift
//  SecureRental
//
//  Created by Anchal Sharma on 2024-11-07.
//

import Foundation
import Combine

class RentalListingsViewModel: ObservableObject {
    @Published var listings: [RentalListing] = []
    @Published var searchText: String = ""
    @Published var selectedAmenities: [String] = []
    @Published var favoriteListings: Set<UUID> = [] // A set of favorite listing IDs

    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Fetch initial data from backend or local storage
        fetchListings()
        
        // Setup search functionality combining search text and selected amenities
        Publishers.CombineLatest($searchText, $selectedAmenities)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates { (prev, current) in
                prev.0 == current.0 && prev.1 == current.1
            }
            .sink { [weak self] (searchTerm, amenities) in
                self?.filterListings(searchTerm: searchTerm, amenities: amenities)
            }
            .store(in: &cancellables)
    }
    
    // Fetches rental listings from the backend or local storage.
    func fetchListings() {
        // Placeholder data; replace with actual backend fetching logic
        listings = [
            RentalListing(
                title: "Cozy Apartment",
                description: "A charming one-bedroom apartment in the heart of downtown.",
                price: "$1200/month",
                imageName: "apartment1",
                location: "Toronto",
                isAvailable: true,
                datePosted: Date(),
                numberOfBedrooms: 1,
                numberOfBathrooms: 1,
                squareFootage: 600,
                amenities: ["WiFi", "Washer/Dryer", "Pet-friendly"],
                street: "123 Main St",
                city: "Toronto",
                province: "ON"
            ),
            RentalListing(
                title: "Luxury Condo",
                description: "Spacious 2-bedroom, 2-bathroom condo with amazing city views.",
                price: "$2500/month",
                imageName: "condo1",
                location: "Toronto",
                isAvailable: false,
                datePosted: Date().addingTimeInterval(-3600),
                numberOfBedrooms: 2,
                numberOfBathrooms: 2,
                squareFootage: 1100,
                amenities: ["Gym", "Parking", "Swimming Pool"],
                street: "456 Elm St",
                city: "Toronto",
                province: "ON"
            )
        ]
    }
    
    // Adds a new rental listing.
    // - Parameter listing: The `RentalListing` to add.
    func addListing(_ listing: RentalListing) {
        listings.append(listing)
        // TODO: Add backend call to save the listing
    }
    
    // Updates an existing rental listing.
    // - Parameter listing: The `RentalListing` with updated information.
    func updateListing(_ listing: RentalListing) {
        if let index = listings.firstIndex(where: { $0.id == listing.id }) {
            listings[index] = listing
            // TODO: Add backend call to update the listing
        }
    }
    
    // Filters listings based on search text and selected amenities.
    // - Parameters:
    //   - searchTerm: The text input by the user for searching.
    //   - amenities: The list of amenities selected by the user for filtering.
    private func filterListings(searchTerm: String, amenities: [String]) {
        if searchTerm.isEmpty && amenities.isEmpty {
            fetchListings()
        } else {
            listings = listings.filter { listing in
                let matchesSearch = searchTerm.isEmpty ||
                    listing.title.lowercased().contains(searchTerm.lowercased()) ||
                    listing.description.lowercased().contains(searchTerm.lowercased())
                
                let matchesAmenities = amenities.isEmpty ||
                    amenities.allSatisfy { listing.amenities.contains($0) }
                
                return matchesSearch && matchesAmenities
            }
        }
    }
    
    // Toggle favorite status
     func toggleFavorite(for listing: RentalListing) {
         if favoriteListings.contains(listing.id) {
             favoriteListings.remove(listing.id)
         } else {
             favoriteListings.insert(listing.id)
         }
     }

     // Check if the listing is a favorite
     func isFavorite(_ listing: RentalListing) -> Bool {
         return favoriteListings.contains(listing.id)
     }

     // Add a rating or comment to a listing
//     func addComment(to listing: RentalListing, comment: String) {
//         if let index = listings.firstIndex(where: { $0.id == listing.id }) {
//             listings[index].comments.append(comment)
//         }
//     }
//
//     func addRating(to listing: RentalListing, rating: Int) {
//         if let index = listings.firstIndex(where: { $0.id == listing.id }) {
//             listings[index].ratings.append(rating)
//         }
//     }
}

