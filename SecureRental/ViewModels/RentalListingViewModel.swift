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
    
    @Published var showLocationConsentAlert: Bool = false
    @Published var isLoading: Bool = false // ✅ loading state


    
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
    
    func fetchListings() {
        Task {
            do {
                let fetched = try await dbHelper.fetchListings()
                await MainActor.run {
                    self.listings = fetched.filter { $0.isAvailable }
                }
                await fetchFavoriteListings() // sync favorites after fetching listings

            } catch {
                print("❌ Failed to fetch listings: \(error.localizedDescription)")
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
//                await fetchListings() // refresh after save
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
            Task {
                do {
                    await loadHomePageListings(forceReload: true)
                } catch {
                    print("❌ Failed to loadHomePageListings : \(error.localizedDescription)")
                }
            }
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
    
    

    // Fetch device location
    @MainActor
    func getDeviceLocation() async -> CLLocationCoordinate2D? {
        let service = LocationService()
        return await service.requestLocation()
    }

    // Calculate distance in km between two points
    func distanceBetween(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let earthRadius = 6371.0
        let dLat = (lat2 - lat1) * .pi / 180
        let dLon = (lon2 - lon1) * .pi / 180
        let a = sin(dLat/2) * sin(dLat/2) +
                cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) *
                sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        return earthRadius * c
    }

    // Fetch nearby listings based on latitude/longitude
    @MainActor
    func fetchListingsNearby(latitude: Double, longitude: Double, radiusInKm: Double = 6.0) async {
        do {
            let allListings = try await dbHelper.fetchListings()
            let nearby = allListings.filter { listing in
                guard let lat = listing.latitude, let lon = listing.longitude else { return false }
                return listing.isAvailable && distanceBetween(lat1: latitude, lon1: longitude, lat2: lat, lon2: lon) <= radiusInKm
            }
            listings = nearby
            await fetchFavoriteListings()
        } catch {
            print("❌ Failed to fetch nearby listings: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func loadHomePageListings(forceReload: Bool = false) async {
        guard let user = dbHelper.currentUser else {
            showLocationConsentAlert = true
            return
        }

//        if !listings.isEmpty { return } // Don't reload if already have listings

        switch (user.locationConsent, user.latitude, user.longitude) {
        case (nil, _, _):
            showLocationConsentAlert = true
        case (true, let lat?, let lon?):
            
//            await dbHelper.updateLocationConsent(consent: true,
//                                                 latitude: 43.7791987,
//                                                 longitude: -79.4172125)
//            await fetchListingsNearby(latitude: 43.7791987, longitude: -79.4172125)
            
            // set up the location manually because simulator will pick up the user's device simulator current location (because simulator doesn't have toronto time setup)
            await fetchListingsNearby(latitude: lat, longitude: lon) // this picks up the user's current location
        case (true, nil, nil):
            if let location = await getDeviceLocation() {
//                await dbHelper.updateLocationConsent(consent: true,
//                                                    latitude: location.latitude,
//                                                    longitude: location.longitude)
                await dbHelper.updateLocationConsent(consent: true,
                                                     latitude: 43.7791987,
                                                     longitude: -79.4172125)
                
                await fetchListingsNearby(latitude: location.latitude,
                                          longitude: location.longitude)
            }
        case (false, _, _):
            await fetchListings()
        @unknown default:
            await fetchListings()
        }
    }

        
        @MainActor
        func handleLocationConsentResponse(granted: Bool) async {
//            if granted, let location = await getDeviceLocation() {
//                dbHelper.currentUser?.locationConsent = true
//                dbHelper.currentUser?.latitude = location.latitude
//                dbHelper.currentUser?.longitude = location.longitude
//                await dbHelper.updateLocationConsent(consent: true,
//                                                    latitude: location.latitude,
//                                                    longitude: location.longitude)
//                await fetchListingsNearby(latitude: location.latitude, longitude: location.longitude)
//            }
            if granted {
                dbHelper.currentUser?.locationConsent = true

                dbHelper.currentUser?.latitude = 43.7791987
                dbHelper.currentUser?.longitude = -79.4172125
                let setLatitude = 43.7791987
                let setLongitude = -79.4172125
                await dbHelper.updateLocationConsent(consent: true,
                                                     latitude: setLatitude,
                                                     longitude: setLongitude)
                await fetchListingsNearby(latitude: setLatitude, longitude: setLongitude)
                
            } else {
                dbHelper.currentUser?.locationConsent = false
                await dbHelper.updateLocationConsent(consent: false)
                await fetchListings()
            }
            showLocationConsentAlert = false
        }

}
