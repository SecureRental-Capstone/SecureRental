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

    // map
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    @EnvironmentObject var dbHelper: FireDBHelper
    @StateObject var viewModel = RentalListingsViewModel()

    @State private var showCommentView = false

    // location consent
    @State private var showLocationConsentAlert = false
    @State private var isConsentFlowLoading = false
    @State private var shouldOpenDirectionsAfterConsent = false
    @State private var showMapPicker = false

    // chat/navigation state
    @State private var activeConversationId: String?
    @State private var shouldNavigateToChat = false

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {

                    // images
                    if !listing.imageURLs.isEmpty {
                        CarouselView(imageURLs: listing.imageURLs)
                            .frame(height: 300)
                    }

                    Text(listing.title)
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)

                    Text("$\(listing.price)/month")
                        .font(.title)
                        .foregroundColor(.green)
                        .bold()

                    Divider()

                    // description
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Description:")
                            .font(.headline)
                        Text(listing.description)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)

                    Divider()

                    // address
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Location:")
                            .font(.headline)
                        Text("\(listing.street), \(listing.city), \(listing.province)")
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)

                    Divider()

                    // property details
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Property Details:")
                            .font(.headline)

                        HStack {
                            Label("\(listing.numberOfBedrooms) Bedrooms", systemImage: "bed.double.fill")
                                .foregroundColor(.blue)
                            Label("\(listing.numberOfBathrooms) Bathrooms", systemImage: "drop.fill")
                                .foregroundColor(.blue)
                        }

                        HStack {
                            Label("\(listing.squareFootage) sq ft", systemImage: "ruler")
                                .foregroundColor(.blue)
                            if listing.isAvailable {
                                Text("Available")
                                    .foregroundColor(.green)
                                    .padding(6)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(8)
                            } else {
                                Text("Not Available")
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

                    // directions
                    Button {
                        if let user = dbHelper.currentUser, user.locationConsent == true {
                            showMapPicker = true
                        } else {
                            shouldOpenDirectionsAfterConsent = true
                            isConsentFlowLoading = true
                            showLocationConsentAlert = true
                        }
                    } label: {
                        Label("Open Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    Divider()

                    // amenities
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Amenities:")
                            .font(.headline)
                        ForEach(listing.amenities, id: \.self) { amenity in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                                Text(amenity)
                            }
                        }
                    }
                    .padding(.horizontal)

                    // actions
                    if listing.landlordId != Auth.auth().currentUser?.uid {
                        HStack(spacing: 48) {
                            // MESSAGE
                            VStack {
                                Button {
                                    Task {
                                        await openOrCreateChat()
                                    }
                                } label: {
                                    Image(systemName: "message.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.blue)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .clipShape(Circle())
                                }
                                Text("Message")
                                    .font(.footnote)
                            }

                            // favourite
                            VStack {
                                Button {
                                    withAnimation(.spring()) {
                                        viewModel.toggleFavorite(for: listing)
                                    }
                                } label: {
                                    Image(systemName: viewModel.isFavorite(listing) ? "heart.fill" : "heart")
                                        .font(.system(size: 28))
                                        .foregroundColor(viewModel.isFavorite(listing) ? .red : .gray)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .clipShape(Circle())
                                }
                                Text("Favourite")
                                    .font(.footnote)
                            }
                        }
                        .padding(.vertical, 20)

                        Button {
                            showCommentView = true
                        } label: {
                            Label("Rate / Review", systemImage: "star.circle.fill")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .background(Color.orange)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)

                    } else {
                        Text("You are the landlord for this listing")
                            .foregroundColor(.gray)
                            .italic()
                            .padding()
                    }

                    Divider()

                    // reviews
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Reviews")
                            .font(.headline)

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

            // loading overlay for location
            if isConsentFlowLoading {
                Color.black.opacity(0.05)
                    .ignoresSafeArea()
                ProgressView("Preparing directions…")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            }

            // 👇 hidden navigation link lives here, inside ZStack, not in .background
            NavigationLink(
                isActive: $shouldNavigateToChat,
                destination: {
                    Group {
                        if let convId = activeConversationId {
                            ChatView(listing: listing, conversationId: convId)
                        } else {
                            EmptyView()
                        }
                    }
                },
                label: {
                    EmptyView()
                }
            )
            .hidden()
        }
        // location alert
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
                    if shouldOpenDirectionsAfterConsent {
                        showMapPicker = true
                    }
                    isConsentFlowLoading = false
                    shouldOpenDirectionsAfterConsent = false
                }
            }
        }
        // map picker
        .confirmationDialog("Open directions in…", isPresented: $showMapPicker, titleVisibility: .visible) {
            Button("Apple Maps") { openInAppleMaps() }
            Button("Google Maps") { openInGoogleMaps() }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Chat
    private func openOrCreateChat() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        do {
            let conv = try await dbHelper.getOrCreateConversation(
                listingId: listing.id,
                landlordId: listing.landlordId,
                tenantId: currentUserId
            )
            await MainActor.run {
                self.activeConversationId = conv.id
                self.shouldNavigateToChat = true
            }
        } catch {
            print("❌ failed to open/create chat: \(error)")
        }
    }

    // MARK: - Map helpers
    private func geocodeAddressWithAnimation() {
        let geocoder = CLGeocoder()
        let address = "\(listing.street), \(listing.city), \(listing.province)"

        geocoder.geocodeAddressString(address) { placemarks, error in
            if let placemark = placemarks?.first, let location = placemark.location {
                withAnimation(.easeInOut(duration: 1.2)) {
                    self.region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
                    )
                }
            } else if let error = error {
                print("❌ Geocoding failed: \(error.localizedDescription)")
            }
        }
    }

    private func openInAppleMaps() {
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
        let currentLocationItem = MKMapItem.forCurrentLocation()

        MKMapItem.openMaps(
            with: [currentLocationItem, destinationMapItem],
            launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ]
        )
    }

    private func openInGoogleMaps() {
        let address = "\(listing.street), \(listing.city), \(listing.province)"
        let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "comgooglemaps://?daddr=\(encoded)&directionsmode=driving"
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            let webUrlString = "https://www.google.com/maps/dir/?api=1&destination=\(encoded)"
            if let webUrl = URL(string: webUrlString) {
                UIApplication.shared.open(webUrl)
            }
        }
    }
}
