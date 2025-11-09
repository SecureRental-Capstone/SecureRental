//
//  RentalListingDetailView.swift
//  SecureRental
//
//  Created by Anchal Sharma on 2024-11-07.
//

import SwiftUI
import MapKit
import CoreLocation
import FirebaseAuth
import Contacts

struct MapLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct RentalListingDetailView: View {
    var listing: Listing
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832), // Default to Toronto
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var locationItem: MapLocation?
    
    @EnvironmentObject var dbHelper: FireDBHelper
    @StateObject var viewModel = RentalListingsViewModel()
    @State private var showCommentView = false

    // 👇 existing states
    @State private var showLocationConsentAlert = false
    @State private var isConsentFlowLoading = false
    @State private var shouldOpenDirectionsAfterConsent = false

    // 👇 NEW: show Apple vs Google picker
    @State private var showMapPicker = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Swipeable Carousel View for Image
                    if !listing.imageURLs.isEmpty {
                        CarouselView(imageURLs: listing.imageURLs)
                            .frame(height: 300)
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
                    
                    Text("Map")
                        .font(.headline)
                        .padding(.top, 10)

                    Map(
                        coordinateRegion: $region,
                        annotationItems: [MapLocation(coordinate: region.center)]
                    ) { location in
                        MapMarker(coordinate: location.coordinate, tint: .red)
                    }
                    .frame(height: 200)
                    .cornerRadius(12)
                    .onAppear {
                        geocodeAddressWithAnimation()
                    }
                    
                    
                    // 🧭 Open Directions Button
                    Button(action: {
                        // 👇 check consent first
                        if let user = dbHelper.currentUser, user.locationConsent == true {
                            // instead of going straight to Apple, show picker
                            showMapPicker = true
                        } else {
                            shouldOpenDirectionsAfterConsent = true
                            isConsentFlowLoading = true
                            showLocationConsentAlert = true
                        }
                    }) {
                        Label("Open Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    
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
                    
                    // Actions Row
                    if listing.landlordId != Auth.auth().currentUser?.uid {
                        HStack(spacing: 48) {
                            // Message Action
                            VStack {
//                                NavigationLink(destination: ChatView(listing: listing)) {
//                                    Image(systemName: "message.fill")
//                                        .font(.system(size: 28))
//                                        .foregroundColor(.blue)
//                                        .padding()
//                                        .background(Color(.systemGray6))
//                                        .clipShape(Circle())
//
                                if let currentUserId = Auth.auth().currentUser?.uid {
                                               // build the same channel id we use in StreamChatManager
                                               let shortListing = String(listing.id.prefix(12))
                                               let shortTenant  = String(currentUserId.prefix(12))
                                               let channelId = "lst-\(shortListing)-t-\(shortTenant)"

                                               NavigationLink(
                                                   destination: StreamChatDetailView(
                                                       listing: listing,
                                                       landlordId: listing.landlordId,
                                                       channelId: channelId   // 👈 pass it
                                                   )
                                               ) {
                                                   Image(systemName: "message.fill")
                                                       .font(.system(size: 28))
                                                       .foregroundColor(.blue)
                                                       .padding()
                                                       .background(Color(.systemGray6))
                                                       .clipShape(Circle())
                                               }
                                           } else {
                                               // optional: show disabled button if not signed in
                                               Image(systemName: "message.fill")
                                                   .font(.system(size: 28))
                                                   .foregroundColor(.gray)
                                                   .padding()
                                                   .background(Color(.systemGray6))
                                                   .clipShape(Circle())
                                           }

                                           Text("Message")
                                               .font(.footnote)
                                               .foregroundColor(.primary)
                                       }
                            
                            // Favourites (Heart) Action
                            VStack {
                                Button(action: {
                                    withAnimation(.spring()) {
                                        viewModel.toggleFavorite(for: listing)
                                    }
                                }) {
                                    Image(systemName: viewModel.isFavorite(listing) ? "heart.fill" : "heart")
                                        .font(.system(size: 28))
                                        .foregroundColor(viewModel.isFavorite(listing) ? .red : .gray)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .clipShape(Circle())
                                }
                                Text("Favourite")
                                    .font(.footnote)
                                    .foregroundColor(.primary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        
                        // 👇 Rate / Review ALSO only for non-landlord
                        Button(action: {
                            showCommentView = true
                        }) {
                            Label("Rate / Review", systemImage: "star.circle.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .background(Color.orange)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.12), radius: 2, x: 0, y: 2)
                        }
                        .padding(.horizontal)
                        .padding(.top, 5)
                        
                    } else {
                        Text("You are the landlord for this listing")
                            .foregroundColor(.gray)
                            .italic()
                            .padding()
                    }
                    
                    Spacer()
                    
                    Divider()
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Reviews")
                            .font(.headline)
                            .padding(.bottom, 4)
                        
                        if dbHelper.reviews.isEmpty {
                            Text("No reviews yet. Be the first to review this listing!")
                                .italic()
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(dbHelper.reviews) { review in
                                ReviewRow(review: review)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .task {
                        await dbHelper.fetchReviews(for: listing.id)
                    }

                }
                .padding()
                .navigationTitle(listing.title)
                .sheet(isPresented: $showCommentView) {
                    CommentView(listing: listing)
                        .environmentObject(dbHelper)
                }
            }

            // 👇 overlay while we’re waiting for consent
            if isConsentFlowLoading {
                Color.black.opacity(0.05)
                    .ignoresSafeArea()
                ProgressView("Preparing directions…")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            }
        }
        // 👇 same style alert as your HomeView
        .alert("Allow SecureRental to access your location?", isPresented: $showLocationConsentAlert) {
            Button("No") {
                Task {
                    await viewModel.handleLocationConsentResponse(granted: false)
                    isConsentFlowLoading = false
                    shouldOpenDirectionsAfterConsent = false
                }
            }
            Button("Yes") {
                Task {
                    await viewModel.handleLocationConsentResponse(granted: true)
                    
                    // user originally wanted to open directions
                    if shouldOpenDirectionsAfterConsent {
                        // after consent, NOW show the picker instead of forcing Apple
                        showMapPicker = true
                    }
                    
                    isConsentFlowLoading = false
                    shouldOpenDirectionsAfterConsent = false
                }
            }
        }
        // 👇 NEW: map picker
        .confirmationDialog("Open directions in…", isPresented: $showMapPicker, titleVisibility: .visible) {
            Button("Apple Maps") {
                openInAppleMaps()
            }
            Button("Google Maps") {
                openInGoogleMaps()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private func geocodeAddressWithAnimation() {
        let geocoder = CLGeocoder()
        let address = "\(listing.street), \(listing.city), \(listing.province)"
        
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let placemark = placemarks?.first, let location = placemark.location {
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 1.2)) {
                        self.region = MKCoordinateRegion(
                            center: location.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
                        )
                    }
                }
            } else if let error = error {
                print("❌ Geocoding failed: \(error.localizedDescription)")
            }
        }
    }

    private func openInAppleMaps() {
        // Destination: Listing address
        let destinationPlacemark = MKPlacemark(
            coordinate: region.center,
            addressDictionary: [
                CNPostalAddressStreetKey: listing.street,
                CNPostalAddressCityKey: listing.city,
                CNPostalAddressStateKey: listing.province
            ]
        )
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        destinationMapItem.name = "Rental: \(listing.title)"

        // Source: always device's current location
        let currentLocationItem = MKMapItem.forCurrentLocation()

        MKMapItem.openMaps(
            with: [currentLocationItem, destinationMapItem],
            launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ]
        )
    }


    // 👇 NEW: google maps version
    private func openInGoogleMaps() {
        // build destination from the listing address
        let address = "\(listing.street), \(listing.city), \(listing.province)"
        let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "comgooglemaps://?daddr=\(encoded)&directionsmode=driving"
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            // fallback to web google maps
            let webUrlString = "https://www.google.com/maps/dir/?api=1&destination=\(encoded)"
            if let webUrl = URL(string: webUrlString) {
                UIApplication.shared.open(webUrl)
            }
        }
    }
}
