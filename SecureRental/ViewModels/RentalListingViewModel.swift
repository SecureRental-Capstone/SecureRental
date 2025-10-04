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
import UIKit
import SwiftUICore
import FirebaseAuth
import CoreLocation

@MainActor
class RentalListingsViewModel: ObservableObject {
    @Published var listings: [Listing] = []
    let dbHelper = FireDBHelper.getInstance()
    
    @Published var searchText: String = ""
    @Published var selectedAmenities: [String] = []
    @Published var shouldAutoFilter = true
    
    @Published var favoriteListingIDs: Set<String> = []
    
    // Derived property for favorite listings
    var favouriteListings: [Listing] {
        listings.filter { favoriteListingIDs.contains($0.id) }
    }

    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Publishers.CombineLatest($searchText, $selectedAmenities)
                .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
                .removeDuplicates { (prev, current) in
                    prev.0 == current.0 && prev.1 == current.1
                }
                .sink { [weak self] (searchTerm, amenities) in
                    guard let self = self, self.shouldAutoFilter else { return }
                    self.filterListings(searchTerm: searchTerm, amenities: amenities)
                }
                .store(in: &cancellables)
    }
    
//    func fetchListings() {
//        Task {
//            do {
//                let fetched = try await dbHelper.fetchListings()
//                await MainActor.run {
//                    self.listings = fetched.filter { $0.isAvailable }
//                }
//                await fetchFavoriteListings() // sync favorites after fetching listings
//
//            } catch {
//                print("❌ Failed to fetch listings: \(error.localizedDescription)")
//            }
//        }
//    }
    
    func fetchListings(around location: CLLocation?, radiusInKm: Double = 5.0) {
            Task {
                do {
                    let allListings = try await dbHelper.fetchListings()
                    
                    var filtered = allListings.filter { $0.isAvailable }
                    
                    if let location = location {
                        filtered = filtered.filter { listing in
                            let listingLocation = CLLocation(
                                latitude: listing.latitude,
                                longitude: listing.longitude
                            )
                            return listingLocation.distance(from: location) <= radiusInKm * 1000
                        }
                    }
                    
                    await MainActor.run {
                        self.listings = filtered
                    }
                    
                } catch {
                    print("❌ Failed to fetch listings:", error.localizedDescription)
                }
            }
        }
    

    
    func fetchMyListings() {
        Task {
            do {
                let fetched = try await dbHelper.fetchListingsForCurrentUser()
                await MainActor.run {
                    self.listings = fetched
                }
            } catch {
                print("❌ Failed to fetch my listings: \(error.localizedDescription)")
            }
        }
    }
    
    func addListing(_ listing: Listing, images: [UIImage]) {
        Task {
            do {
                try await dbHelper.addListing(listing, images: images)
                await fetchListings(around: <#CLLocation?#>) // refresh after save
            } catch {
                print("❌ Failed to add listing: \(error.localizedDescription)")
            }
        }
    }
    
    func updateListing(_ listing: Listing) {
        if let index = listings.firstIndex(where: { $0.id == listing.id }) {
            listings[index] = listing
        }
        
        Task {
            do {
                try await dbHelper.updateListing(listing)
            } catch {
                print("❌ Failed to update listing in Firestore: \(error.localizedDescription)")
            }
        }
    }

    func filterListings(searchTerm: String, amenities: [String], showOnlyAvailable: Bool = true) {
        if searchTerm.isEmpty && amenities.isEmpty {
            fetchListings(around: <#CLLocation?#>)
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

    func deleteListing(_ listing: Listing) {
            // Remove locally first
        if let index = listings.firstIndex(where: { $0.id == listing.id }) {
            listings.remove(at: index)
        }
        
            // Remove from Firestore
        Task {
            do {
                try await dbHelper.deleteListing(listing)
            } catch {
                print("❌ Failed to delete listing from Firestore: \(error.localizedDescription)")
                    // Optionally, add it back locally if deletion fails
                await MainActor.run {
                    self.listings.append(listing)
                }
            }
        }
    }
    
    func toggleFavorite(for listing: Listing) {
        Task {
            do {
                try await dbHelper.toggleFavorite(listingId: listing.id)
                self.favoriteListingIDs = Set(dbHelper.currentUser?.favoriteListingIDs ?? [])
            } catch {
                print("❌ Failed to toggle favorite: \(error.localizedDescription)")
            }
        }
    }
    
    func isFavorite(_ listing: Listing) -> Bool {
        favoriteListingIDs.contains(listing.id)
    }
    
    @MainActor
    func fetchFavoriteListings() {
        guard let currentUser = dbHelper.currentUser else { return }
        self.favoriteListingIDs = Set(currentUser.favoriteListingIDs)
    }

}
