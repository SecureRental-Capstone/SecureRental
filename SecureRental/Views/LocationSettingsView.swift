//
//  LocationSettingsView.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-10-19.
//

//
//  LocationSettingsView.swift
//  SecureRental
//
//  Created by Anchal Sharma on 2025-10-19.
//

import SwiftUI
import MapKit
import CoreLocation

struct LocationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: RentalListingsViewModel
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832), // default Toronto
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var radiusInKm: Double = 2.0
    @State private var locationManager = CLLocationManager()
    @State private var preference: LocationPreference? = LocationPreferenceManager.shared.load()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Map
                Map(coordinateRegion: $region, showsUserLocation: true)
                    .frame(height: 300)
                    .cornerRadius(15)
                    .overlay(
                        Circle()
                            .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                            .frame(width: CGFloat(radiusInKm * 100)) // just visual indicator
                    )
                
                // Radius slider
                VStack(alignment: .leading) {
                    Text("Search Radius: \(String(format: "%.1f", radiusInKm)) km")
                        .font(.headline)
                    Slider(value: $radiusInKm, in: 1...10, step: 0.5)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Save button
                Button(action: savePreference) {
                    Text("Save Preferences")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Location Settings")
            .onAppear {
                loadCurrentPreference()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func loadCurrentPreference() {
        if let pref = preference {
            region.center = CLLocationCoordinate2D(latitude: pref.latitude, longitude: pref.longitude)
            radiusInKm = pref.radiusInKm
        } else if let currentLocation = locationManager.location?.coordinate {
            region.center = currentLocation
        }
    }
    
    private func savePreference() {
        let pref = LocationPreference(
            latitude: region.center.latitude,
            longitude: region.center.longitude,
            radiusInKm: radiusInKm,
            consentGiven: true
        )
        LocationPreferenceManager.shared.save(pref)
        viewModel.fetchListingsNear(
            latitude: region.center.latitude,
            longitude: region.center.longitude,
            radiusInKm: radiusInKm
        )
        dismiss()
    }
}

