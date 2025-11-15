//
//  UpdateLocationView.swift
//  SecureRental
//
//  Created by Anchal Sharma on 2025-10-20.
//
import SwiftUI
import MapKit
import CoreLocation


struct IdentifiableCoordinate: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}

struct UpdateLocationView: View {
    @EnvironmentObject var dbHelper: FireDBHelper
    @StateObject var viewModel = RentalListingsViewModel()
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.78017, longitude: -79.457212),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var selectedCoordinate: IdentifiableCoordinate?
    @State private var radius: Double = 5.0       // will be loaded from user
    @State private var isUpdating = false
    @State private var alertMessage: String?
    @State private var isFetchingLocation = false
    
    // 👇 NEW: listings to show as pins on the map
    @State private var nearbyListings: [Listing] = []
    
    /// The radius used for displaying map pins (max 25 km)
    private var effectiveMapRadius: Double {
        return min(radius, 25)
    }
    
    var body: some View {
        ZStack {
            // Background consistent with rest of app
            LinearGradient(
                colors: [
                    Color.hunterGreen.opacity(0.06),
                    Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    // Title + subtitle
                    VStack(spacing: 4) {
                        Text("Update Your Location")
                            .font(.title3.weight(.semibold))
                        
                        Text("Choose where to search for listings and how far around it.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .padding(.top, 8)
                    
                    // Card: Map + radius
                    VStack(spacing: 12) {
                        // Map
                        MapViewRepresentable(
                            region: $region,
                            selectedCoordinate: $selectedCoordinate,
                            nearbyListings: nearbyListings,   // 👈 NEW
                            radiusKm: radius                  // 👈 NEW
                        )
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                        
                        // Radius slider (1–400 km)
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Search radius")
                                    .font(.subheadline.weight(.semibold))
                                
                                Spacer()
                                
                                Text(radiusLabel)
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.hunterGreen)
                            }
                            
                            Slider(value: $radius, in: 1...400, step: 1)
                                .onChange(of: radius) { newValue in
                                    updateMapSpan(for: newValue)
                                    Task { await refreshNearbyListings() }   // 👈 NEW
                                }
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.06),
                                    radius: 4, x: 0, y: 2)
                    )
                    .padding(.horizontal, 16)
                    
                    // Set current location button
                    Button(action: {
                        Task { await setCurrentLocation() }
                    }) {
                        HStack {
                            if isFetchingLocation {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "location.fill")
                                Text("Use My Current Location")
                            }
                        }
                        .font(.subheadline.weight(.semibold))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(isFetchingLocation
                                      ? Color.hunterGreen.opacity(0.6)
                                      : Color.hunterGreen)
                        )
                        .foregroundColor(.white)
                    }
                    .disabled(isFetchingLocation)
                    .padding(.horizontal, 16)
                    
                    // Save button
                    Button(action: {
                        Task { await updateUserLocation() }
                    }) {
                        HStack {
                            if isUpdating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Save Location & Radius")
                                    .font(.subheadline.weight(.semibold))
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.blue)
                        )
                        .foregroundColor(.white)
                    }
                    .disabled(isUpdating)
                    .padding(.horizontal, 16)
                    
                    Spacer(minLength: 12)
                }
                .padding(.bottom, 12)
            }
        }
        .navigationTitle("Update Location")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadUserData()
            Task { await refreshNearbyListings() }   // 👈 NEW
        }
        .alert(
            alertMessage ?? "",
            isPresented: Binding(
                get: { alertMessage != nil },
                set: { newValue in
                    if !newValue { alertMessage = nil }
                }
            )
        ) {
            Button("OK", role: .cancel) { }
        }
    }
    
    // MARK: - Derived
    
    private var radiusLabel: String {
        if radius <= 0 {
            return "Off"
        } else {
            return "\(Int(radius)) km"
        }
    }
    
    // Adjusts zoom level based on radius (km)
    private func updateMapSpan(for radius: Double) {
        // Convert km to degrees roughly (1 degree ~ 111 km)
        let degrees = max(0.01, radius / 111.0)

        // Smooth zooming animation
        withAnimation(.easeInOut(duration: 0.35)) {
            region.span = MKCoordinateSpan(
                latitudeDelta: degrees * 2.0,   // small multiplier for comfortable view
                longitudeDelta: degrees * 2.0
            )
        }
    }

    
    // MARK: - Load User Data
    
    func loadUserData() {
        guard let user = dbHelper.currentUser else { return }
        
        // Set map and pin location
        if let lat = user.latitude, let lon = user.longitude {
            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            region.center = coord
            selectedCoordinate = IdentifiableCoordinate(coordinate: coord)
        }
        
        // Set radius to user's saved radius (default 5 if not found), clamped 0–400
        if let userRadius = user.radius {
            radius = min(max(userRadius, 0), 400)
        } else {
            radius = 5.0
        }
    }
    
    // MARK: - Nearby listings refresh
    
    func refreshNearbyListings() async {
        guard let coord = selectedCoordinate?.coordinate else {
            await MainActor.run { nearbyListings = [] }
            return
        }
        
        do {
            let all = try await FireDBHelper.getInstance().fetchListings()
            
            let filtered = all.filter { listing in
                guard let lat = listing.latitude,
                      let lon = listing.longitude else { return false }
                
                let distance = distanceKm(
                    from: coord,
                    to: CLLocationCoordinate2D(latitude: lat, longitude: lon)
                )
                return distance <= effectiveMapRadius
            }
            
            await MainActor.run {
                self.nearbyListings = filtered
            }
        } catch {
            print("❌ Failed to fetch nearby listings: \(error.localizedDescription)")
            await MainActor.run {
                self.nearbyListings = []
            }
        }
    }
    
    /// Simple Haversine distance in km
    private func distanceKm(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let earthRadius = 6371.0
        
        let dLat = (to.latitude - from.latitude) * .pi / 180
        let dLon = (to.longitude - from.longitude) * .pi / 180
        
        let a = sin(dLat / 2) * sin(dLat / 2) +
            cos(from.latitude * .pi / 180) *
            cos(to.latitude * .pi / 180) *
            sin(dLon / 2) * sin(dLon / 2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return earthRadius * c
    }
    
    // MARK: - Save Updated Location
    
    @MainActor
    func updateUserLocation() async {
        guard let coord = selectedCoordinate?.coordinate else {
            alertMessage = "Please tap or drag the pin to set your location."
            return
        }
        
        isUpdating = true
        await viewModel.updateUserLocation(
            latitude: coord.latitude,
            longitude: coord.longitude,
            radius: radius
        )
        isUpdating = false
        alertMessage = "Location and radius updated successfully!"
    }
    
    // MARK: - Use Device Location
    
    @MainActor
    func setCurrentLocation() async {
        isFetchingLocation = true
        
        guard let currentLocation = await viewModel.getDeviceLocation() else {
            alertMessage = "Unable to get your current location."
            isFetchingLocation = false
            return
        }
        
        let userLatitude = currentLocation.latitude
        let userLongitude = currentLocation.longitude
        
        let coord = CLLocationCoordinate2D(latitude: userLatitude, longitude: userLongitude)
        selectedCoordinate = IdentifiableCoordinate(coordinate: coord)
        region.center = coord
        
        // Update city name based on new coordinates
        await viewModel.updateCityFromStoredCoordinates(
            latitude: userLatitude,
            longitude: userLongitude
        )
        
        alertMessage = "Location set to your current position!"
        
        await refreshNearbyListings()   // 👈 NEW
        
        isFetchingLocation = false
    }
}

