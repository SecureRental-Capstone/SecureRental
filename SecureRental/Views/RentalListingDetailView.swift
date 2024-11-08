//
//  RentalListingDetailView.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2024-11-07.
//

// RentalListingDetailView.swift
import SwiftUI
import MapKit

//struct RentalListingDetailView: View {
//    var listing: RentalListing
//    @State private var region: MKCoordinateRegion
//
//    init(listing: RentalListing) {
//        self.listing = listing
//        _region = State(initialValue: MKCoordinateRegion(
//            center: listing.coordinates,
//            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//        ))
//    }
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 20) {
//                Image(listing.imageName)
//                    .resizable()
//                    .scaledToFit()
//                    .cornerRadius(10)
//                
//                Text(listing.title)
//                    .font(.largeTitle)
//                    .bold()
//                
//                Text(listing.price)
//                    .font(.title2)
//                    .foregroundColor(.green)
//                
//                Text(listing.description)
//                    .font(.body)
//                
//                HStack {
//                    Text("Bedrooms: \(listing.numberOfBedrooms)")
//                    Spacer()
//                    Text("Bathrooms: \(listing.numberOfBathrooms)")
//                }
//                
//                Text("Square Footage: \(listing.squareFootage) sqft")
//                
//                Text("Amenities: \(listing.amenities.joined(separator: ", "))")
//                
//                Map(coordinateRegion: $region, annotationItems: [listing]) { listing in
//                    MapMarker(coordinate: listing.coordinates, tint: .blue)
//                }
//                .frame(height: 300)
//                .cornerRadius(10)
//            }
//            .padding()
//        }
//        .navigationTitle("Listing Details")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
import SwiftUI
import MapKit

struct RentalListingDetailView: View {
    var listing: RentalListing
    @State private var region: MKCoordinateRegion

    init(listing: RentalListing) {
        self.listing = listing
        _region = State(initialValue: MKCoordinateRegion(
            center: listing.coordinates,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }

    var body: some View {
        VStack(spacing: 20) {
            // Image and Title
            Image(listing.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .cornerRadius(10)
            
            Text(listing.title)
                .font(.largeTitle)
                .bold()
            
            // Price and Description
            Text(listing.price)
                .font(.title2)
            Text(listing.description)
                .font(.body)
                .padding()
            
            // Map View
            Map(coordinateRegion: $region)
                .frame(height: 200)
                .cornerRadius(10)

            // Amenities
            VStack(alignment: .leading) {
                Text("Amenities:")
                    .font(.headline)
                ForEach(listing.amenities, id: \.self) { amenity in
                    Text("• \(amenity)")
                }
            }
            .padding()

            Spacer()
        }
        .padding()
        .navigationTitle(listing.title)
    }
}

struct RentalListingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RentalListingDetailView(listing: RentalListing(
            title: "Sample Listing",
            description: "Sample Description",
            price: "$1000/month",
            imageName: "sampleImage",
            location: "Sample Location",
            isAvailable: true,
            datePosted: Date(),
            numberOfBedrooms: 1,
            numberOfBathrooms: 1,
            squareFootage: 500,
            amenities: ["WiFi"],
            coordinates: CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832)
        ))
    }
}
