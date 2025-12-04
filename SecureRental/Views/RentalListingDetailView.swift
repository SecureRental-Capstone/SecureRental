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
    @State private var landlord: AppUser?

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

    @EnvironmentObject var vm: CurrencyViewModel

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 18) {

              
                    if !listing.imageURLs.isEmpty {
                        CarouselView(imageURLs: listing.imageURLs)
                            .frame(height: 280)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                            .padding(.horizontal)
                    }

            
                    SectionBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(listing.title)
                                .font(.title3.weight(.semibold))
                                .multilineTextAlignment(.leading)

                            HStack(alignment: .center, spacing: 8) {
//                                Text("$\(listing.price)/month")
                                Text(vm.convertedPrice(basePriceString: listing.price) + "/mo")
                                    .font(.title3.weight(.bold))
                                    .foregroundColor(.primaryPurple)

                                Spacer()

                                if listing.isAvailable {
                                    Text("Available")
                                        .font(.caption.weight(.semibold))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.primaryPurple.opacity(0.12))
                                        .foregroundColor(.primaryPurple)
                                        .clipShape(Capsule())
                                } else {
                                    Text("Not available")
                                        .font(.caption.weight(.semibold))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.red.opacity(0.10))
                                        .foregroundColor(.red)
                                        .clipShape(Capsule())
                                }
                            }

                            HStack(spacing: 4) {
                                Image(systemName: "mappin.and.ellipse")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(listing.street), \(listing.city), \(listing.province)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

      
                    SectionBox(title: "Property Details") {
                        HStack(spacing: 16) {
                            Label("\(listing.numberOfBedrooms) bed", systemImage: "bed.double.fill")
                            Label("\(listing.numberOfBathrooms) bath", systemImage: "drop.fill")
                            Label("\(listing.squareFootage) sq ft", systemImage: "ruler")
                        }
                        .font(.caption)
                        .foregroundColor(.primaryPurple)

                        let trimmedDescription = listing.description
                            .trimmingCharacters(in: .whitespacesAndNewlines)

                        if !trimmedDescription.isEmpty {
                            Divider().padding(.vertical, 4)
                            Text(trimmedDescription)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }


                    if !listing.amenities.isEmpty {
                        SectionBox(title: "Amenities") {
                            FlexibleAmenityChips(amenities: listing.amenities)
                        }
                    }

             
                    SectionBox(title: "Location on Map") {
                        Map(
                            coordinateRegion: $region,
                            annotationItems: [MapLocation(coordinate: region.center)]
                        ) { location in
                            MapMarker(coordinate: location.coordinate, tint: .primaryPurple)
                        }
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 14))

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
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .background(Color.primaryPurple)
                                .cornerRadius(10)
                        }
                    }
                    .onAppear {
                        geocodeAddressWithAnimation()
                    }

                
                    SectionBox {
                        HStack {
                            Text("Landlord")
                                .font(.headline)
                            Spacer()
                            Text("Verified")
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.14))
                                .foregroundColor(Color(red: 34/255, green: 139/255, blue: 34/255))
                                .clipShape(Capsule())
                        }

                        if let landlord {
                            NavigationLink {
                                LandlordProfileView(landlord: landlord).environmentObject(vm)
                            } label: {
                                UserRow(user: landlord, subtitle: "View profile & other listings")
                            }
                        } else {
                            Text("Loading landlord info…")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        }
                    }

            
                    if listing.landlordId != Auth.auth().currentUser?.uid {
                        SectionBox {
                            VStack(spacing: 10) {
                                HStack(spacing: 12) {
                                    // Message – primary
                                    Button {
                                        Task {
                                            await openOrCreateChat()
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: "message.fill")
                                            Text("Message")
                                        }
                                        .font(.footnote.weight(.semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 150, height: 40)
                                        .background(Color.primaryPurple)
                                        .cornerRadius(10)
                                    }

                                    // Favourite – secondary
                                    Button {
                                        withAnimation(.spring()) {
                                            viewModel.toggleFavorite(for: listing)
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: viewModel.isFavorite(listing) ? "heart.fill" : "heart")
                                            Text("Favourite")
                                        }
                                        .font(.footnote.weight(.semibold))
                                        .foregroundColor(viewModel.isFavorite(listing) ? .red : .primaryPurple)
                                        .frame(width: 150, height: 40)
                                        .background(Color.primaryPurple.opacity(0.08))
                                        .cornerRadius(10)
                                    }
                                }.frame(maxWidth: .infinity, alignment: .center)

                                Button {
                                    showCommentView = true
                                } label: {
                                    HStack {
                                        Image(systemName: "star.circle.fill")
                                        Text("Add a Review")
                                    }
                                    .font(.footnote.weight(.semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 200, height: 40)
                                    .background(Color.orange)
                                    .cornerRadius(10)
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                    } else {
                        SectionBox {
                            Text("You are the landlord for this listing")
                                .foregroundColor(.secondary)
                                .font(.footnote.italic())
                        }
                    }

                    SectionBox(title: "Reviews") {
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
                    .task {
                        await dbHelper.fetchReviews(for: listing.id)
                    }

                    Spacer(minLength: 16)
                }
                .padding(.top, 10)
                .navigationTitle("Listing details")
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $showCommentView) {
                    CommentView(listing: listing)
                        .environmentObject(dbHelper)
                }
                .task {
                    if landlord == nil {
                        landlord = await dbHelper.getUser(byUID: listing.landlordId)
                    }
                }
            }

      
            if isConsentFlowLoading {
                Color.black.opacity(0.05)
                    .ignoresSafeArea()
                ProgressView("Preparing directions…")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            }

     
            NavigationLink(
                isActive: $shouldNavigateToChat,
                destination: {
                    Group {
                        if let convId = activeConversationId {
                            ChatView(listing: listing, conversationId: convId).environmentObject(vm)
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
  
        .confirmationDialog("Open directions in…", isPresented: $showMapPicker, titleVisibility: .visible) {
            Button("Apple Maps") { openInAppleMaps() }
            Button("Google Maps") { openInGoogleMaps() }
            Button("Cancel", role: .cancel) {}
        }
    }


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
            print(" failed to open/create chat: \(error)")
        }
    }


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
                print(" Geocoding failed: \(error.localizedDescription)")
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


struct FlexibleAmenityChips: View {
    let amenities: [String]

    var body: some View {
        FlexibleView(
            data: amenities,
            spacing: 8,
            alignment: .leading
        ) { amenity in
            Text(amenity)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.primaryPurple.opacity(0.08))
                .foregroundColor(.primaryPurple)
                .clipShape(Capsule())
        }
    }
}



struct FlexibleView<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content

    init(
        data: Data,
        spacing: CGFloat,
        alignment: HorizontalAlignment,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }

    var body: some View {
        var width: CGFloat = 0
        var height: CGFloat = 0

        return GeometryReader { geometry in
            ZStack(alignment: Alignment(horizontal: alignment, vertical: .top)) {
                ForEach(Array(data), id: \.self) { item in
                    content(item)
                        .padding(.all, 4)
                        .alignmentGuide(.leading) { d in
                            if (abs(width - d.width) > geometry.size.width) {
                                width = 0
                                height -= d.height + spacing
                            }
                            let result = width
                            if item == data.last {
                                width = 0 // reset
                            } else {
                                width -= d.width + spacing
                            }
                            return result
                        }
                        .alignmentGuide(.top) { _ in
                            let result = height
                            if item == data.last {
                                height = 0 // reset
                            }
                            return result
                        }
                }
            }
        }
        .frame(height: intrinsicHeight)
    }

    // Fallback height; GeometryReader will expand as needed
    private var intrinsicHeight: CGFloat { 100 }
}



struct SectionBox<Content: View>: View {
    let title: String?
    let content: Content

    init(title: String? = nil,
         @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title {
                Text(title)
                    .font(.headline)
            }

            content
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}
