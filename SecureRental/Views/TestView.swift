//////
//////  TestView.swift
//////  SecureRental
//////
//////  Created by Haniya Akhtar on 2025-11-18.
//////
////
import SwiftUI

// This view relies on all other files (Models, View Models, and Views)
struct StudyStayAppUI: View {
    // StateObject must be initialized here and passed down.
    @StateObject var currencyManager = CurrencyViewModel()
    @State private var searchText: String = ""
    @State private var selectedTab: String = "Search"
    
    // Mock Data (Requires Listing definition from Models.swift)
    let mockListings: [Listing] = [
        Listing(title: "Luxury Apt near Campus", description: "Modern and spacious.", price: "1500", imageURLs: ["https://placehold.co/600x400/0000FF/FFFFFF?text=Apt+1"], location: "123 Main St, Toronto, ON", isAvailable: true, numberOfBedrooms: 2, numberOfBathrooms: 2, squareFootage: 850, amenities: ["Gym", "Pool"], street: "123 Main St", city: "Toronto", province: "ON", datePosted: Date(), landlordId: "2"),
        Listing(title: "Cozy Studio Downtown", description: "Perfect for single student.", price: "900", imageURLs: ["https://placehold.co/600x400/FF0000/FFFFFF?text=Studio"], location: "45 Queen St, London, UK", isAvailable: true, numberOfBedrooms: 1, numberOfBathrooms: 1, squareFootage: 400, amenities: ["WiFi"], street: "45 Queen St", city: "London", province: "UK", datePosted: Date(), landlordId: "3"),
        Listing(title: "House for 3 Students", description: "Spacious house near Uni.", price: "2700", imageURLs: ["https://placehold.co/600x400/00FF00/000000?text=House+3"], location: "88 University Ave, Sydney, AU", isAvailable: false, numberOfBedrooms: 3, numberOfBathrooms: 2, squareFootage: 1200, amenities: ["Yard", "Laundry"], street: "88 University Ave", city: "Sydney", province: "AU", datePosted: Date(), landlordId: "4")
    ]
    
    var body: some View {
        // Use a ZStack to layer the scrollable content and the persistent tab bar
        ZStack(alignment: .bottom) {
            
            // Scrollable Content
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // MARK: Header Bar (SecureRental + Currency)
                    HStack {
                        Text("SecureRental")
                            .font(.title3.weight(.bold))
                            .foregroundColor(.blue)
                        Spacer()
                        
                        if !currencyManager.currencies.isEmpty {
                            // Uses CurrencyPickerButton.swift
                            CurrencyPickerButton(selected: $currencyManager.selectedCurrency,
                                                 options: currencyManager.currencies)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // MARK: Search and Filter Bar
                    HStack(spacing: 8) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Search location or university...", text: $searchText)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 15)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        
                        // Filter Button
                        Button {
                            // Action for filter
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                                .font(.title3)
                                .foregroundColor(.primary)
                                .padding(10)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // MARK: Verified Housing Banner
                    HStack(alignment: .top) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Verified Student Housing")
                                .font(.callout.weight(.bold))
                                .foregroundColor(.white)
                            
                            Text("7 verified listings near universities")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .underline()
                        }
                        Spacer()
                    }
                    .padding(16)
                    .background(Color.blue)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // MARK: Results Count
                    Text("\(mockListings.count) properties found")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.top, 20)
                    
                    // MARK: Listing Cards
                    LazyVStack(spacing: 20) {
                        ForEach(mockListings) { listing in
                            // Uses the renamed component
                            RentalListingCardView(listing: listing, vm: currencyManager)
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.bottom, 100) // Space for the tab bar
                }
            }
            .navigationBarHidden(true)
            
            // MARK: Persistent Bottom Tab Bar
            // Uses CustomTabBar.swift
            CustomTabBar(selectedTab: $selectedTab)
        }
    }
}

struct StudyStayAppUI_Previews: PreviewProvider {
    static var previews: some View {
        StudyStayAppUI()
    }
}
