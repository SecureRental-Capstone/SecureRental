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
//        .alert(item: $alertMessage) { msg in
//            Alert(title: Text("Info"), message: Text(msg), dismissButton: .default(Text("OK")))
//        }
        .onAppear {
            if let user = dbHelper.currentUser,
               let lat = user.latitude,
               let lon = user.longitude {
                let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                region.center = coord
                selectedCoordinate = IdentifiableCoordinate(coordinate: coord)
            }
        }
    }
    
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
}
