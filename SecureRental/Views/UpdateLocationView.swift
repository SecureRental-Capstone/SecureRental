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
    @State private var radius: Double = 5.0
    @State private var isUpdating = false
    @State private var alertMessage: String?
    @State private var isFetchingLocation = false
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Update Your Location")
                .font(.headline)
            
            // Map with draggable annotation
            MapViewRepresentable(
                region: $region,
                selectedCoordinate: $selectedCoordinate
            )
            .frame(height: 350)
            .cornerRadius(12)
            
            // Radius slider
            HStack {
                Text("Search Radius: \(Int(radius)) km")
                Slider(value: $radius, in: 1...50, step: 1)
            }
            .padding(.horizontal)
            
            // Set current location
            Button(action: {
                Task { await setCurrentLocation() }
            }) {
                HStack {
                    if isFetchingLocation {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "location.fill")
                        Text("Set Current Location")
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(isFetchingLocation ? Color.green.opacity(0.6) : Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isFetchingLocation)   // 👈 disable while loading
            .padding(.horizontal)
            
            // Save button
            Button(action: {
                Task { await updateUserLocation() }
            }) {
                if isUpdating {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Save Location").bold()
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal)
            .disabled(isUpdating)
        }
        .padding()
        .navigationTitle("Update Location")
        .onAppear {
            loadUserData()
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
        
        // ✅ Set radius to user's saved radius (default 5 if not found)
        if let userRadius = user.radius {
            radius = userRadius
        } else {
            radius = 5.0
        }
    }
    
    // MARK: - Save Updated Location
    @MainActor
    func updateUserLocation() async {
        guard let coord = selectedCoordinate?.coordinate else {
            alertMessage = "Please set or drag the pin to your location."
            return
        }
        
        isUpdating = true
        await viewModel.updateUserLocation(
            latitude: coord.latitude,
            longitude: coord.longitude,
            radius: radius
        )
        isUpdating = false
        alertMessage = "Location updated successfully!"
    }
    
    @MainActor
    func setCurrentLocation() async {
        // start loading
        isFetchingLocation = true
       
        // try to get device location
        guard let currentLocation = await viewModel.getDeviceLocation() else {
            alertMessage = "Unable to get your current location."
            return
        }

        let userlatitude = currentLocation.latitude
        let userLongitude = currentLocation.longitude
        
//        // Hardcoded coordinates
//        let userlatitude = 43.7791987
//        let userLongitude = -79.4172125
      
        // Update map pin and region
        let coord = CLLocationCoordinate2D(latitude: userlatitude, longitude: userLongitude)
        selectedCoordinate = IdentifiableCoordinate(coordinate: coord)
        region.center = coord
        
        // Update city from coordinates
        await viewModel.updateCityFromStoredCoordinates(latitude: userlatitude, longitude: userLongitude)
        
        //        // Save user location to Firestore and local user object
        //        await viewModel.updateUserLocation(latitude: userlatitude,
        //                                           longitude: userLongitude,
        //                                           radius: hardcodedRadius)
        
        alertMessage = "Location set to predefined coordinates!"
        
        // stop loading
        isFetchingLocation = false
        
    }


}
