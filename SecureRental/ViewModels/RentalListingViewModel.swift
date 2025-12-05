//
//  RentalListingViewModel.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2024-11-07.
//


import Foundation
import Combine
import UIKit
import SwiftUI
//import SwiftUICore
import FirebaseAuth
import CoreLocation


@MainActor
class RentalListingsViewModel: ObservableObject {
    @Published var listings: [Listing] = []
    @Published var locationListings: [Listing] = []
    @Published var allListings: [Listing] = []

    let dbHelper = FireDBHelper.getInstance()
    
    @Published var searchText: String = ""
    @Published var selectedAmenities: [String] = []
    @Published var shouldAutoFilter = true
    
    @Published var favoriteListingIDs: Set<String> = []
    
    @Published var showLocationConsentAlert: Bool = false
    @Published var isLoading: Bool = false // ✅ loading state
    
    @Published var showUpdateLocationSheet = false
    @Published var currentCity: String?
    @Published var listingReviews: [Review] = []


    var favouriteListings: [Listing] {
        fetchListings()
        return listings.filter { favoriteListingIDs.contains($0.id) }
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
                print(" Failed to fetch listings: \(error.localizedDescription)")
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
                print(" Failed to fetch my listings: \(error.localizedDescription)")
            }
        }
    }
    
    func addListing(_ listing: Listing, images: [UIImage]) {
        Task {
            do {
                try await dbHelper.addListing(listing, images: images)
//                await fetchListings() // refresh after save
            } catch {
                print(" Failed to add listing: \(error.localizedDescription)")
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
                print(" Failed to update listing in Firestore: \(error.localizedDescription)")
            }
        }
    }

    func filterListings(searchTerm: String, amenities: [String], showOnlyAvailable: Bool = true) {
        if searchTerm.isEmpty && amenities.isEmpty {
            Task {
                do {
                    await loadHomePageListings(forceReload: true)
                } catch {
                    print(" Failed to loadHomePageListings : \(error.localizedDescription)")
                }
            }
        } else {
            locationListings = locationListings.filter { listing in
                    let matchesSearch = searchTerm.isEmpty ||
                        listing.title.lowercased().contains(searchTerm.lowercased()) ||
                        listing.description.lowercased().contains(searchTerm.lowercased())
                    
                    let matchesAmenities = amenities.isEmpty ||
                        amenities.allSatisfy { listing.amenities.contains($0) }
                    
                    return matchesSearch && matchesAmenities
                }
        }
    }
    
    func filterListingsNew(searchTerm: String, amenities: [String], showOnlyAvailable: Bool = true) {
        // Always start filtering from the original unfiltered list
        var filtered = locationListings

        // Search text
        if !searchTerm.isEmpty {
            let lower = searchTerm.lowercased()
            filtered = filtered.filter { listing in
                listing.title.lowercased().contains(lower) ||
                listing.description.lowercased().contains(lower)
            }
        }

        // Amenities
        if !amenities.isEmpty {
            filtered = filtered.filter { listing in
                amenities.allSatisfy { listing.amenities.contains($0) }
            }
        }

        // Availability
        if showOnlyAvailable {
            filtered = filtered.filter { $0.isAvailable }
        }

        // Push filtered results to UI array
        self.locationListings = filtered
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
                print(" Failed to delete listing from Firestore: \(error.localizedDescription)")
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
                print(" Failed to toggle favorite: \(error.localizedDescription)")
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
    func fetchListingsNearby(latitude: Double, longitude: Double) async {
        do {
            let allListings = try await dbHelper.fetchListings()
            let radiusInKm = self.dbHelper.currentUser?.radius ?? 5.0
            let nearby = allListings.filter { listing in
                guard let lat = listing.latitude, let lon = listing.longitude else { return false }
                return listing.isAvailable && distanceBetween(lat1: latitude, lon1: longitude, lat2: lat, lon2: lon) <= radiusInKm
            }
            locationListings = nearby
            await fetchFavoriteListings()
        } catch {
            print(" Failed to fetch nearby listings: \(error.localizedDescription)")
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
            

            // Hardcoded current location
//            await fetchListingsNearby(latitude: 43.7791987, longitude: -79.4172125)
            
            // set up the location manually because simulator will pick up the user's device simulator current location (because simulator doesn't have toronto time setup)
            await fetchListingsNearby(latitude: lat, longitude: lon) // this picks up the user's current location
        case (true, nil, nil):
            if let location = await getDeviceLocation() {
                await dbHelper.updateLocationConsent(consent: true,
                                                    latitude: location.latitude,
                                                    longitude: location.longitude,
                                                    radius: 5.0)
                
                
                await fetchListingsNearby(latitude: location.latitude,
                                          longitude: location.longitude)
            }
        case (false, _, _):
            await fetchListings()
            self.locationListings = self.listings   // 👈 add this
        @unknown default:
            await fetchListings()
            self.locationListings = self.listings
        }
    }

        
        @MainActor
        func handleLocationConsentResponse(granted: Bool) async {
            if granted, let location = await getDeviceLocation() {
                dbHelper.currentUser?.locationConsent = true
                dbHelper.currentUser?.latitude = location.latitude
                dbHelper.currentUser?.longitude = location.longitude
                dbHelper.currentUser?.radius = 5.0
                let setRadius = 5.0
                await dbHelper.updateLocationConsent(consent: true,
                                                    latitude: location.latitude,
                                                    longitude: location.longitude,
                                                     radius: setRadius)
                await fetchListingsNearby(latitude: location.latitude, longitude: location.longitude)

                
            } else {
                locationListings = listings
                dbHelper.currentUser?.locationConsent = false
                await dbHelper.updateLocationConsent(consent: false)
                await fetchListings()
            }
            showLocationConsentAlert = false
        }
    
    @MainActor
    func updateUserLocation(latitude: Double, longitude: Double, radius: Double) async {
        guard let user = dbHelper.currentUser else { return }
        
        await updateCityFromStoredCoordinates(latitude: latitude, longitude: longitude)
        
        // Save to Firestore
        await dbHelper.updateUserLocation(userId: user.id, latitude: latitude, longitude: longitude, radius: radius)

        dbHelper.currentUser?.latitude = latitude
        dbHelper.currentUser?.longitude = longitude
        dbHelper.currentUser?.radius = radius
        
        
        // Reload listings based on new location
        await fetchListingsNearby(latitude: latitude, longitude: longitude)
    }
    
    // Reverse-geocode coordinates to city/province
    @MainActor
    func updateCityFromStoredCoordinates(latitude: Double?, longitude: Double?) async {
        guard let lat = latitude, let lon = longitude else { return }
        let geocoder = CLGeocoder()
        if let placemark = try? await geocoder.reverseGeocodeLocation(CLLocation(latitude: lat, longitude: lon)).first {
            if let city = placemark.locality, let province = placemark.administrativeArea {
                self.currentCity = "\(city), \(province)"
            } else {
                self.currentCity = "Unknown"
            }
        }
    }
    @MainActor
    func addReview(for listing: Listing, rating: Double, comment: String) async {
        guard let user = dbHelper.currentUser else { return }
        
        dbHelper.addReview(to: listing, rating: rating, comment: comment, user: user)
        
            // Refresh reviews after adding
        await dbHelper.fetchReviews(for: listing.id)
    }
    @MainActor
    func fetchReviews(for listingId: String) async {
        print(" [VM] fetchReviews called for listing:", listingId)
        listingReviews = []      // clear previous reviews
        
        await dbHelper.fetchReviews(for: listingId)
        print("[VM] dbHelper.reviews after fetch =", dbHelper.reviews.count)
            // Sync from FireDBHelper into your VM
        listingReviews = dbHelper.reviews
        print(" [VM] listingReviews stored =", listingReviews.count)
    }
    
    func openStreetView(lat: Double, lng: Double) {
        // Google Maps Street View URL scheme
        let urlString = "comgooglemaps://?center=\(lat),\(lng)&mapmode=streetview"
        
        if let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // Fallback: open in browser if Google Maps app is not installed
                let webString = "https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=\(lat),\(lng)"
                if let webURL = URL(string: webString) {
                    UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
                }
            }
        }
    }


}
