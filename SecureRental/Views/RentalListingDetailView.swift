//
//  RentalListingDetailView.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2024-11-07.
//

// RentalListingDetailView.swift
import SwiftUI
import MapKit
import CoreLocation



struct RentalListingDetailView: View {
    var listing: Listing
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832), // Default to Toronto
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        ScrollView{
            VStack(spacing: 20) {
                // Image and Title
                ForEach(listing.imageURLs, id: \.self) { image in
                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .cornerRadius(10)
                }
                
                Text(listing.title)
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 5)
                
                Text("$\(listing.price)/month")
                    .font(.title)
                    .foregroundColor(.green)
                    .bold()
                
                Divider()
                
                // Display property description
                VStack(alignment: .leading, spacing: 5) {
                    Text("Description:")
                        .font(.headline)
                        .padding(.bottom, 2)
                    Text(listing.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                }
                .padding(.horizontal)
                
                Divider()
                
                
                // Display address
                VStack(alignment: .leading, spacing: 5) {
                    Text("Location:")
                        .font(.headline)
                        .padding(.bottom, 2)
                    Text("\(listing.street), \(listing.city), \(listing.province)")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                Divider()
                
                // Display additional property details
                VStack(alignment: .leading, spacing: 5) {
                    Text("Property Details:")
                        .font(.headline)
                        .padding(.bottom, 2)
                    
                    HStack {
                        Label("\(listing.numberOfBedrooms) Bedrooms", systemImage: "bed.double.fill")
                            .font(.body)
                            .foregroundColor(.blue)
                        Label("\(listing.numberOfBathrooms) Bathrooms", systemImage: "drop.fill")
                            .font(.body)
                            .foregroundColor(.blue)
                    }
                    
                    HStack {
                        Label("\(listing.squareFootage) sq ft", systemImage: "ruler")
                            .font(.body)
                            .foregroundColor(.blue)
                        if listing.isAvailable {
                            Text("Available")
                                .font(.body)
                                .foregroundColor(.green)
                                .padding(6)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                        } else {
                            Text("Not Available")
                                .font(.body)
                                .foregroundColor(.red)
                                .padding(6)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
                
                
                Divider()
                
                // Map View with Geocoding for location
                Text("Map")
                    .font(.headline)
                    .padding(.top, 10)
                Map(coordinateRegion: $region)
                    .frame(height: 200)
                    .cornerRadius(12)
                    .onAppear {
                        geocodeAddress()
                    }
                
                Divider()
                
                // Display Amenities
                VStack(alignment: .leading, spacing: 10) {
                    Text("Amenities:")
                        .font(.headline)
                        .padding(.bottom, 2)
                    ForEach(listing.amenities, id: \.self) { amenity in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                            Text(amenity)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle(listing.title)
        }
    }
    
    // Function to geocode the address for the map view
    private func geocodeAddress() {
        let geocoder = CLGeocoder()
        let address = "\(listing.street), \(listing.city), \(listing.province)"
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let placemark = placemarks?.first, let location = placemark.location {
                DispatchQueue.main.async {
                    self.region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                }
            }
        }
    }
}
