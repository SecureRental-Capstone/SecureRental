//
//  RentalListingViewModel.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2024-11-07.
//

import Foundation
import Combine
import CoreLocation

class RentalListingsViewModel: ObservableObject {
    @Published var listings: [RentalListing] = []
    @Published var searchText: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Fetch initial data from backend or local storage
        fetchListings()
        
        // Setup search functionality
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchTerm in
                self?.filterListings(by: searchTerm)
            }
            .store(in: &cancellables)
    }
    
    func fetchListings() {
        // will replace with actual backend fetching logic later
        listings = [
            RentalListing(
                title: "Cozy Apartment",
                description: "A charming one-bedroom apartment in the heart of downtown.",
                price: "$1200/month",
                imageName: "apartment1",
                location: "Toronto, ON",
                isAvailable: true,
                datePosted: Date(),
                numberOfBedrooms: 1,
                numberOfBathrooms: 1,
                squareFootage: 600,
                amenities: ["WiFi", "Washer/Dryer", "Pet-friendly"],
                coordinates: CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832)
            ),
            RentalListing(
                title: "Luxury Condo",
                description: "Spacious 2-bedroom, 2-bathroom condo with amazing city views.",
                price: "$2500/month",
                imageName: "condo1",
                location: "Toronto, ON",
                isAvailable: false,
                datePosted: Date().addingTimeInterval(-3600),
                numberOfBedrooms: 2,
                numberOfBathrooms: 2,
                squareFootage: 1100,
                amenities: ["Gym", "Parking", "Swimming Pool"],
                coordinates: CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832)

            )
        ]
    }
    
    func addListing(_ listing: RentalListing) {
        listings.append(listing)
        // Add backend call to save the listing
    }
    
    func updateListing(_ listing: RentalListing) {
        if let index = listings.firstIndex(where: { $0.id == listing.id }) {
            listings[index] = listing
            // Add backend call to update the listing
        }
    }
    
    private func filterListings(by searchTerm: String) {
        if searchTerm.isEmpty {
            fetchListings()
        } else {
            listings = listings.filter { $0.title.lowercased().contains(searchTerm.lowercased()) || $0.description.lowercased().contains(searchTerm.lowercased()) }
        }
    }
}
