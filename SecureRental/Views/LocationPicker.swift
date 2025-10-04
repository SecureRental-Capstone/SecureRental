//
//  LocationPicker.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-10-04.
//

import SwiftUI
import MapKit

struct LocationPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var locationManager: LocationManager
    
    @State private var tempCoordinate: CLLocationCoordinate2D?
    @State private var tempRadius: Double = 5.0
    @State private var region: MKCoordinateRegion
    
    init(locationManager: LocationManager) {
        self.locationManager = locationManager
        // Initial region: either selectedLocation or a default
        if let coordinate = locationManager.selectedLocation {
            _region = State(initialValue: MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
            _tempCoordinate = State(initialValue: coordinate)
        } else {
            _region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832), // Default Toronto
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }
        _tempRadius = State(initialValue: locationManager.radiusInKm)
    }
    
    var body: some View {
        NavigationView {
            VStack {
//                Map(coordinateRegion: $region, interactionModes: [.all], annotationItems: tempCoordinate != nil ? [tempCoordinate!] : []) { coordinate in
//                    MapMarker(coordinate: coordinate, tint: .blue)
//                }
                
                Map(coordinateRegion: $region,
                    interactionModes: [.all],
                    annotationItems: tempCoordinate != nil ? [MapLocation(coordinate: tempCoordinate!)] : []) { location in
                        MapMarker(coordinate: location.coordinate, tint: .blue)
                    }
                
//                Map(coordinateRegion: $region,
//                    interactionModes: [.all],
//                    annotationItems: tempCoordinate != nil ? [tempCoordinate!].map { $0 } : []) { coordinate in
//                        MapMarker(coordinate: coordinate, tint: .blue)
//                    }
//                    .id(UUID()) // not recommended for dynamic updates

                .frame(height: 400)
                .cornerRadius(12)
                .onTapGesture {
                    // optional: add gesture to move marker
                }
                
                HStack {
                    Text("Radius: \(Int(tempRadius)) km")
                    Slider(value: $tempRadius, in: 1...50, step: 1)
                }
                .padding()
                
                Button("Set Location") {
                    if tempCoordinate == nil {
                        tempCoordinate = region.center
                    }
                    if let coord = tempCoordinate {
                        locationManager.updateLocation(coord, radius: tempRadius)
                    }
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.borderedProminent)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Pick Location & Radius")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
