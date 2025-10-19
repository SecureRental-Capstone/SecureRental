//
//  HomeViewModel.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-10-19.
//

import Foundation
import CoreLocation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var listings: [Listing] = []
    @Published var showLocationPrompt = false
    
    private let dbHelper = FireDBHelper.getInstance()
    private let locationHelper = LocationHelper()

    func loadListings() async {
        guard let user = dbHelper.currentUser else { return }

        if user.locationConsent,
           let lat = user.latitude,
           let lon = user.longitude,
           let radius = user.preferredRadius {

            let allListings = try? await dbHelper.fetchListings()
            let filtered = allListings?.filter { listing in
                // Assuming Listing has lat/lon fields — if not, we’ll use approximate city-based matching later
                let distance = CLLocation(latitude: lat, longitude: lon).distance(from:
                    CLLocation(latitude: listing.latitude ?? 0, longitude: listing.longitude ?? 0))
                return distance <= radius * 1000
            } ?? []
            listings = filtered
        } else {
            listings = (try? await dbHelper.fetchListings()) ?? []
        }
    }

    func handleFirstLoginLocationPrompt() {
        guard let user = dbHelper.currentUser else { return }
        if user.locationConsent == false {
            showLocationPrompt = true
        }
    }

    func updateLocationConsent(granted: Bool) async {
        if granted {
            locationHelper.requestPermission()
            await MainActor.run {
                if let loc = locationHelper.userLocation {
                    Task {
                        try? await dbHelper.updateUserLocationPreference(consent: true,
                                                                        latitude: loc.coordinate.latitude,
                                                                        longitude: loc.coordinate.longitude,
                                                                        radius: 2.0)
                    }
                }
            }
        } else {
            try? await dbHelper.updateUserLocationPreference(consent: false,
                                                             latitude: nil,
                                                             longitude: nil,
                                                             radius: 2.0)
        }
    }
}
