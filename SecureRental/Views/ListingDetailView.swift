////
////  ListingDetailView.swift
////  SecureRental
////
////  Created by Haniya Akhtar on 2025-11-18.
////
import SwiftUI
import MapKit

/// The detailed view displayed when a user taps on a rental listing card.
struct ListingDetailView: View {
    @State private var showMapPicker = false
    @EnvironmentObject var viewModel: RentalListingsViewModel

    let listing: Listing
    @ObservedObject var vm: CurrencyViewModel
    // Environment property to dismiss the view (used for the custom back button)
    @Environment(\.dismiss) var dismiss
    // map
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var showReviewSheet = false

    // Helper structure for Review data based on screenshots
//    struct MockReview: Identifiable {
//        let id = UUID()
//        let initial: String
//        let name: String
//        let date: String
//        let rating: Double // 1.0 to 5.0
//        let comment: String
//        let isVerified: Bool
//    }
    
    // Mock Review Data for the screenshot
//    private let mockReviews: [MockReview] = [
//        .init(initial: "E", name: "Emma Zhang", date: "Oct 2024", rating: 5.0, comment: "Great apartment! Perfect location near campus. The landlord is very responsive and the place was exactly as described. Highly recommend for international students.", isVerified: true),
//        .init(initial: "C", name: "Carlos Rodriguez", date: "Sep 2024", rating: 4.0, comment: "Nice place, good amenities. Only minor issue was the heating in winter, but landlord fixed it quickly. Would definitely recommend.", isVerified: true),
//        .init(initial: "P", name: "Priya Sharma", date: "Aug 2024", rating: 5.0, comment: "Absolutely loved living here! Safe neighborhood, close to university, and great value for money. Perfect for students.", isVerified: false)
//    ]
    
    // Maps listing amenity strings to a system icon
    private func iconForAmenity(_ amenity: String) -> String {
        switch amenity.lowercased() {
        case "wi-fi": return "wifi"
        case "parking": return "car.fill"
        case "a/c": return "snowflake"
        case "heating": return "drop.triangle.fill"
        default: return "checkmark.circle.fill"
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // MARK: Scrollable Content
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // MARK: - 1. Image and Header Buttons
                    ZStack(alignment: .top) {
                        // Image/Image Carousel (Using a single image for now)
                        AsyncImage(url: URL(string: listing.imageURLs.first ?? "")) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Color(.systemGray4)
                        }
                        .frame(height: 350)
                        .clipped()
                        
                        // Header Buttons: Back and Share
                        HStack {
                            // Back Button
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "chevron.backward.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.black)
                                    .background(Color.white.opacity(0.8))
                                    .clipShape(Circle())
                            }
                            
                            Spacer()
                            
                            // Share Button
                            Button {
                                // Action to share the listing
                            } label: {
                                Image(systemName: "square.and.arrow.up.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.black)
                                    .background(Color.white.opacity(0.8))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 50)
                    }
                    
                    // MARK: - 2. Details Section
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Title and Price
                        HStack(alignment: .lastTextBaseline) {
                            // Use listing title from model
                            Text(listing.title)
                                .font(.largeTitle.weight(.bold))
                                .lineLimit(2)
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                // Converted Price
                                Text(vm.convertedPrice(basePriceString: listing.price))
                                    .font(.title2.weight(.bold))
                                    .foregroundColor(Color.blue)
                                Text("per month")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Location
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.secondary)
                            Text(listing.city + ", " + listing.province)
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Proximity Pill (using mock data to match the screenshot)
                        Text("0.5 miles from MIT\n~10 min walk or 3 min bike ride")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .padding(10)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                        
                        // --- Separator ---
                        Divider()
                        
                        // Beds and Baths
                        HStack(spacing: 20) {
                            HStack {
                                Image(systemName: "bed.double.fill")
                                    .foregroundColor(.blue)
                                Text("\(listing.numberOfBedrooms) Bedrooms")
                            }
                            HStack {
                                Image(systemName: "bathtub.fill")
                                    .foregroundColor(.blue)
                                Text("\(listing.numberOfBathrooms) Bathrooms")
                            }
                        }
                        .font(.title3)
                        
                        // --- Separator ---
                        Divider()
                        
                        // MARK: Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.title2.bold())
                            
                            Text(listing.description)
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                        
                        // --- Separator ---
                        Divider()
                        
                        // MARK: Amenities (New Section from Screenshot)
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Amenities")
                                .font(.title2.bold())
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(listing.amenities, id: \.self) { amenity in
                                    HStack {
                                        Image(systemName: iconForAmenity(amenity))
                                            .foregroundColor(.gray)
                                        Text(amenity)
                                            .font(.subheadline)
                                        Spacer()
                                    }
                                    .padding(15)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        
                        // --- Separator ---
                        Divider()
                        // MARK: - MAP + DIRECTIONS
                        SectionBox(title: "Location on Map") {
                            Map(
                                coordinateRegion: $region,
                                annotationItems: [MapLocation(coordinate: region.center)]
                            ) { location in
                                MapMarker(coordinate: location.coordinate, tint: .hunterGreen)
                            }
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            
                            Button {
                                //                                if let user = dbHelper.currentUser, user.locationConsent == true {
                                //                                    showMapPicker = true
                                //                                } else {
                                //                                    shouldOpenDirectionsAfterConsent = true
                                //                                    isConsentFlowLoading = true
                                //                                    showLocationConsentAlert = true
                                //                                }
                                showMapPicker = true //FIX LATER
                            } label: {
                                Label("Open Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, minHeight: 44)
                                    .background(Color.hunterGreen)
                                    .cornerRadius(10)
                            }
                        }
                        .onAppear {
                            //geocodeAddressWithAnimation()
                            Task {
                                await viewModel.dbHelper.fetchReviews(for: listing.id)
                            }

                        }
                        
                        // MARK: Landlord Section (New Section from Screenshot)
                        VStack(alignment: .leading, spacing: 15) {
                            VStack(alignment: .leading, spacing: 15) {
                                HStack(spacing: 15) {
                                    // Landlord Initial Circle
                                    Text(String(listing.landlordId)) //SHOULD BE NAME
                                        .font(.title.weight(.bold))
                                        .foregroundColor(.white)
                                        .frame(width: 50, height: 50)
                                        .background(Color.purple) // Using purple for a distinct look
                                        .clipShape(Circle())
                                    
                                    VStack(alignment: .leading) {
                                        Text(listing.landlordId) //SHOULD BE NAME
                                            .font(.headline)
                                        
                                        HStack(spacing: 5) {
                                            Image(systemName: "star.fill")
                                                .foregroundColor(.yellow)
                                                .font(.caption)
                                            Text("\(String(format: "%.1f", listing.averageRating ?? 0))") //LANDLORD RATING
                                                .font(.subheadline.weight(.semibold))
                                            //                                            Text("• Responds \(listing.responseTime)") //DO THIS?
                                            //                                                .foregroundColor(.secondary)
                                        }
                                        .font(.subheadline)
                                    }
                                    Spacer()
                                }
                                
                                // Landlord Action Buttons
                                HStack(spacing: 10) {
                                    Button(action: { /* Call action */ }) {
                                        HStack {
                                            Image(systemName: "message.fill")
                                            Text("Message")
                                        }
                                        .padding(.vertical, 12)
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.blue)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color.blue.opacity(0.5))
                                        )
                                        .font(.headline)
                                    }
                                    
                                    //                                    Button(action: { /* Email action */ }) {
                                    //                                        HStack {
                                    //                                            Image(systemName: "envelope.fill")
                                    //                                            Text("Email")
                                    //                                        }
                                    //                                        .padding(.vertical, 12)
                                    //                                        .frame(maxWidth: .infinity)
                                    //                                        .foregroundColor(.blue)
                                    //                                        .background(
                                    //                                            RoundedRectangle(cornerRadius: 15)
                                    //                                                .stroke(Color.blue.opacity(0.5))
                                    //                                        )
                                    //                                        .font(.headline)
                                    //                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6).opacity(0.6))
                            .cornerRadius(15)
                        }
                        
                        // --- Separator ---
                        Divider()
                        
                        // MARK: Security & Safety (New Section from Screenshot)
                        //                        VStack(alignment: .leading, spacing: 10) {
                        //                            HStack {
                        //                                Image(systemName: "lock.shield.fill")
                        //                                    .foregroundColor(.green)
                        //                                Text("Security & Safety")
                        //                                    .font(.title2.bold())
                        //                                    .foregroundColor(.green)
                        //                            }
                        //
                        //                            VStack(alignment: .leading, spacing: 8) {
                        //                                // Verified Landlord
                        //                                HStack(alignment: .top) {
                        //                                    Image(systemName: "checkmark.circle.fill")
                        //                                        .foregroundColor(.green)
                        //                                        .offset(y: 2)
                        //                                    Text("Verified landlord identity")
                        //                                        .font(.body)
                        //                                }
                        //
                        //                                // Background Checked
                        //                                HStack(alignment: .top) {
                        //                                    Image(systemName: "checkmark.circle.fill")
                        //                                        .foregroundColor(.green)
                        //                                        .offset(y: 2)
                        //                                    Text("Background checked property")
                        //                                        .font(.body)
                        //                                }
                        //                            }
                        //                        }
                        
                        // --- Separator ---
                        Divider()
                        
                        // MARK: Reviews (New Section from Screenshot)
                        VStack(alignment: .leading, spacing: 15) {
                            // Review Header
                            HStack {
                                Text("Reviews")
                                    .font(.title2.bold())
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("\(String(format: "%.1f", 4.7)) (\(3))") // Mocked summary rating
                                    .font(.title3)
                                
                                Spacer()
                                
                                Button("Write Review") {
                                    showReviewSheet = true
                                }
                                .font(.headline)
                                .foregroundColor(.blue)

                            }
                            
                            // Individual Review Cards
                            ForEach(viewModel.dbHelper.reviews) { review in
                                RealReviewCardView(review: review)
                            }

                        }
                        
                        // Add extra padding to ensure content scrolls above the sticky footer
                        Color.clear.frame(height: 120)
                        
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .sheet(isPresented: $showReviewSheet) {
                CommentView(listing: listing)
                    .environmentObject(viewModel.dbHelper)
            }

            .edgesIgnoringSafeArea(.top)
            .navigationBarHidden(true)
            
            //            // MARK: - 3. Sticky Footer Action Buttons
            //            VStack(spacing: 5) {
            //                // Top row: Directions and Message
            //                HStack(spacing: 10) {
            //                    Button(action: { /* Directions action */ }) {
            //                        HStack {
            //                            Image(systemName: "arrow.triangle.turn.up.right.diamond")
            //                            Text("Directions")
            //                        }
            //                        .padding()
            //                        .frame(maxWidth: .infinity)
            //                        .background(Color(.systemGray6))
            //                        .cornerRadius(15)
            //                        .foregroundColor(.blue)
            //                        .font(.headline)
            //                    }
            //
            //                    Button(action: { /* Message action */ }) {
            //                        HStack {
            //                            Image(systemName: "message.fill")
            //                            Text("Message")
            //                        }
            //                        .padding()
            //                        .frame(maxWidth: .infinity)
            //                        .background(Color.blue)
            //                        .cornerRadius(15)
            //                        .foregroundColor(.white)
            //                        .font(.headline)
            //                    }
            //                }
            //
            //                // Bottom row: Schedule Viewing (Full Width)
            //                Button(action: { /* Schedule Viewing action */ }) {
            //                    HStack {
            //                        Image(systemName: "calendar")
            //                        Text("Schedule Viewing")
            //                    }
            //                    .padding()
            //                    .frame(maxWidth: .infinity)
            //                    .background(Color(.systemBlue))
            //                    .cornerRadius(15)
            //                    .foregroundColor(.white)
            //                    .font(.headline.weight(.semibold))
            //                }
            //            }
            //            .padding(.horizontal, 20)
            //            .padding(.top, 10)
            //            .padding(.bottom, 30) // Adjusted for modern safe area
            //            .background(Color.white.ignoresSafeArea(.all, edges: .bottom))
            //            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: -5)
            //        }
            //    }
            //}
        }
    }
           //  MARK: - Review Card Subview (Helper to keep main body clean)
//            struct ReviewCardView: View {
//                let review: ListingDetailView.MockReview
//                
//                var body: some View {
//                    VStack(alignment: .leading, spacing: 10) {
//                        HStack(alignment: .top) {
//                            // Initial Circle
//                            Text(review.initial)
//                                .font(.title2)
//                                .foregroundColor(.white)
//                                .frame(width: 40, height: 40)
//                                .background(Color.purple.opacity(0.8)) // Use a distinct color for initials
//                                .clipShape(Circle())
//                            
//                            VStack(alignment: .leading, spacing: 4) {
//                                // Name and Date
//                                HStack {
//                                    Text(review.name)
//                                        .font(.headline)
//                                    
//                                    if review.isVerified {
//                                        Text("Verified")
//                                            .font(.caption2.bold())
//                                            .foregroundColor(.white)
//                                            .padding(.horizontal, 6)
//                                            .padding(.vertical, 2)
//                                            .background(Color.green)
//                                            .cornerRadius(5)
//                                    }
//                                    
//                                    Spacer()
//                                }
//                                Text(review.date)
//                                    .font(.subheadline)
//                                    .foregroundColor(.gray)
//                            }
//                            
//                            Spacer()
//                            
//                            // Rating Stars
//                            HStack(spacing: 2) {
//                                ForEach(0..<5) { index in
//                                    Image(systemName: index < Int(review.rating.rounded(.down)) ? "star.fill" : "star")
//                                        .foregroundColor(.yellow)
//                                }
//                            }
//                        }
//                        
//                        // Comment
//                        Text(review.comment)
//                            .font(.body)
//                            .foregroundColor(.gray)
//                    }
//                    .padding(.vertical, 10)
//                }
//            }
            
        }
    //}
