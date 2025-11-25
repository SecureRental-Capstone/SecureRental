////////
////////  TestView.swift
////////  SecureRental
////////
////////  Created by Haniya Akhtar on 2025-11-18.

import SwiftUI

struct SecureRentalHomePage: View {

    let fireDBHelper : FireDBHelper = FireDBHelper.getInstance()

    @Binding var rootView : RootView
    @State private var showFilterCard = false
    @State private var maxPrice: Double = 5000
    @State private var selectedBedrooms: Int? = nil
    @State private var showVerifiedOnly = false
    @State private var hasWifi = false
    @State private var hasParking = false
    @State private var isPetFriendly = false
    @State private var hasGym = false

    @StateObject var currencyManager = CurrencyViewModel()
    @StateObject var viewModel = RentalListingsViewModel()
    
    @EnvironmentObject var dbHelper: FireDBHelper



    @State private var selectedTab: String = "Search"
    @State private var showAddListing = false
    @State private var showChatbot = false
    @State private var showUpdateLocationSheet = false
    @State private var float = false
//    @State private var showTooltip = false

    @State private var showHint = true



    var body: some View {
        ZStack(alignment: .bottom) {

            // MAIN CONTENT
            VStack(spacing: 0) {

                // Hidden NavigationLinks for programmatic navigation
                NavigationLink(
                    destination: ChatbotView(),
                    isActive: $showChatbot
                ) { EmptyView() }

                NavigationLink(
                    destination: CreateRentalListingView(viewModel: viewModel),
                    isActive: $showAddListing
                ) { EmptyView() }

                // --- MAIN TAB CONTENT (switches by selectedTab) ---
                Group {
                    switch selectedTab {
                    case "Search":
                        exploreContent
                    case "Messages":
                        MyChatsView()
                    case "Favourites":
                        FavouriteListingsView(viewModel: viewModel).environmentObject(fireDBHelper).environmentObject(viewModel)
                    case "Profile":
                        ProfileView(rootView: $rootView)
                    default: // Explore
                        exploreContent
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // TAB BAR
                CustomTabBar(selectedTab: $selectedTab)
                    .zIndex(3)
            }
            .ignoresSafeArea(.keyboard)

            // FILTER OVERLAY + CARD (layered above everything when active)
            if showFilterCard {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { showFilterCard = false }
                    }
                    .zIndex(10)

                FilterCardView(
                    isVisible: $showFilterCard,
                    maxPrice: maxPrice,
                    selectedBedrooms: selectedBedrooms,
                    showVerifiedOnly: showVerifiedOnly,
                    hasWifi: hasWifi,
                    hasParking: hasParking,
                    isPetFriendly: isPetFriendly,
                    hasGym: hasGym,
                    applyAction: { newMax, newBeds, newVerif, newWifi, newPark, newPet, newGym in
                        maxPrice = newMax
                        selectedBedrooms = newBeds
                        showVerifiedOnly = newVerif
                        hasWifi = newWifi
                        hasParking = newPark
                        isPetFriendly = newPet
                        hasGym = newGym
                    },
                    resetAction: {
                        maxPrice = 5000
                        selectedBedrooms = nil
                        showVerifiedOnly = false
                        hasWifi = false
                        hasParking = false
                        isPetFriendly = false
                        hasGym = false
                    },
                    onLocationClick: {
                        showUpdateLocationSheet = true   // << NAVIGATE!
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(11)
                .environmentObject(currencyManager)
                .environmentObject(viewModel)
            }
            // -------------------------------------------------------------
        }
        .sheet(isPresented: $showUpdateLocationSheet) {
            NavigationStack {
                UpdateLocationView(
                    viewModel: viewModel,
                    onBack: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            showFilterCard = true
                        }
                    }
                )
                .environmentObject(fireDBHelper)
            }
        }

        }

    

    // -------------------------------------------------------------
    // MARK: Explore (original listing feed) extracted as a View
    // -------------------------------------------------------------
    private var exploreContent: some View {
        VStack(spacing: 0) {
            
            HStack {
                Text("SecureRental")
                    .font(.title3).bold()

                Spacer()
                AddListingButton {
                    showAddListing = true
                }
                CurrencyPickerButton(
                    selected: $currencyManager.selectedCurrency,
                    options: currencyManager.currencies
                )
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 10)
            
            // SEARCH + FILTER ROW
            HStack(spacing: 12) {
                SearchBar().environmentObject(viewModel)

                FilterButton {
                    withAnimation { showFilterCard = true }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)

            // LISTING FEED
            ScrollView(.vertical, showsIndicators: false) {

                let filteredListings = applyLocalFilters(to: viewModel.locationListings)

                // --- LOADING ---
                if viewModel.isLoading {
                    LazyVStack(spacing: 20) {
                        ForEach(0..<6, id: \.self) { _ in
                            SkeletonListingCardView()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)

                    // --- EMPTY ---
                } else if filteredListings.isEmpty {

                    VStack(spacing: 10) {
                        Image(systemName: "tray")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.7))

                        Text("No listings found in your area.")
                            .font(.headline)

                        Text("Try expanding your radius or updating your location.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)

                    // --- SUCCESS ---
                } else {

                    Text("\(filteredListings.count) properties found")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.top, 20)

                    LazyVStack(spacing: 20) {
                        ForEach(filteredListings) { listing in
                            NavigationLink {
//                                ListingDetailView(vm: currencyManager, listing: listing).environmentObject(viewModel).environmentObject(fireDBHelper)
                                RentalListingDetailView(listing: listing)
                                    .environmentObject(dbHelper)
                            } label: {
                                RentalListingCardView(listing: listing, vm: currencyManager)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.bottom, 100)
                }
            }
            .environmentObject(viewModel)
            .zIndex(0)
            .overlay(alignment: .bottomTrailing) {
                
                VStack(spacing: 6) {
                    
                        // HINT BUBBLE
                    if showHint {
                        Text("Ask a question")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.75))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .transition(.opacity)
                    }
                    
                        // CHATBOT BUTTON
                    Button(action: { showChatbot = true }) {
                        Image("chatbot2")
                       
                            .resizable()
                            .scaledToFit()
                            .frame(width: 58, height: 56)
                            .padding(14)
                            .background(Color.white.opacity(0.97))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color(.systemGray5), lineWidth: 2)
                            )
                            // Soft iOS shadow
                            .shadow(color: Color.blue.opacity(0.15), radius: 12, y: 6)
                            // Floating animation
                            .offset(y: float ? -8 : 0)
                            .animation(
                                Animation.easeInOut(duration: 1.8)
                                    .repeatCount(4, autoreverses: true),
                                value: float
                            )
                    }
                }
                .padding(.trailing, 16)
                .padding(.bottom, 8)
            }
            .onAppear {
                float = true
                showHint = true
                
                    // Hide hint after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    withAnimation { showHint = false }
                }
            }

        }
    }

    // -------------------------------------------------------------
    // MARK: SEARCH BAR
    // -------------------------------------------------------------
    struct SearchBar: View {
        @State private var text = ""
        @EnvironmentObject var viewModel: RentalListingsViewModel

        var body: some View {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search rentals...", text: $text)
                    .onChange(of: text) { newValue in
                        viewModel.filterListingsNew(
                            searchTerm: newValue,
                            amenities: [] // or pass real selected amenities
                        )
                    }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }


    // -------------------------------------------------------------
    // MARK: FILTER BUTTON
    // -------------------------------------------------------------
    struct FilterButton: View {
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 20))
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
        }
    }

    func applyLocalFilters(to listings: [Listing]) -> [Listing] {
        print("📦 LOADED LISTINGS COUNT:", listings.count)
        for l in listings {
            print(" - RAW PRICE:", l.price)
        }
        
        var filtered = listings
        
            // ---------------------------------------------------------
            // 🔥 PRICE FILTER (now converts CAD → selected currency!)
            // ---------------------------------------------------------
//        filtered = filtered.filter { listing in
//            
//                // 1. Clean the price string (Firestore stores strings)
//            let cleaned = listing.price
//                .trimmingCharacters(in: .whitespacesAndNewlines)
//                .components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted)
//                .joined()
//            
//            let cadValue = Double(cleaned) ?? 0
//            
//                // 2. Convert CAD → selected currency (USD/EUR/etc.)
//            let convertedValue = currencyManager.convertToSelectedCurrency(cadValue)
//            
//                // Debug print
//            print("""
//        🔎 PRICE FILTER ->
//        id: \(listing.id)
//        raw: \(listing.price)
//        cleaned: \(cleaned)
//        cadValue: \(cadValue)
//        convertedValue: \(convertedValue)
//        maxPrice(selected currency): \(maxPrice)
//        """)
//            
//            return convertedValue <= maxPrice
//        }
        filtered = filtered.filter { listing in
            // Clean Firestore price string
            let cleaned = listing.price
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted)
                .joined()

            let cadValue = Double(cleaned) ?? 0

            // Convert listing price to selected currency
            let listingInSelectedCurrency = currencyManager.convertToSelectedCurrency(cadValue)

            // Convert slider value to selected currency
            let maxPriceInSelectedCurrency = currencyManager.convertToSelectedCurrency(maxPrice)

            return listingInSelectedCurrency <= maxPriceInSelectedCurrency
        }
        
            // ---------------------------------------------------------
            //  BEDROOM FILTER
            // ---------------------------------------------------------
        if let beds = selectedBedrooms {
            filtered = filtered.filter { listing in
                let pass: Bool
                
                if beds == 3 {
                    pass = listing.numberOfBedrooms >= 3
                } else {
                    pass = listing.numberOfBedrooms == beds
                }
                
                print("🛏 BED FILTER -> id: \(listing.id) actualBeds: \(listing.numberOfBedrooms) selected: \(beds) pass: \(pass)")
                return pass
            }
        }
        
            // ---------------------------------------------------------
            //  VERIFIED PROPERTIES FILTER
            // ---------------------------------------------------------
        if showVerifiedOnly {
            filtered = filtered.filter { listing in
                print("🔐 VERIFIED FILTER -> id:\(listing.id) isAvailable:\(listing.isAvailable)")
                return listing.isAvailable
            }
        }
        
        print("""
    ---------------------------------------------------------
    FINAL FILTERED COUNT: \(filtered.count)
    maxPrice(\(currencyManager.selectedCurrency.code)) = \(maxPrice)
    selectedBedrooms = \(String(describing: selectedBedrooms))
    verifiedOnly = \(showVerifiedOnly)
    ---------------------------------------------------------
    """)
        
        return filtered
    }




    func resetFilters() {
        maxPrice = 5000
        selectedBedrooms = nil
        showVerifiedOnly = false
    }

    struct CurrencySelectorButton: View {
        @State private var currency = "CAD"

        var body: some View {
            Menu {
                Button("CAD") { currency = "CAD" }
                Button("EUR") { currency = "EUR" }
                Button("GBP") { currency = "GBP" }
            } label: {
                HStack {
                    Text(currency)
                    Image(systemName: "chevron.down")
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }

    struct AddListingButton: View {
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Image(systemName: "plus.square.on.square.fill")
                    .font(.system(size: 26))
            }
        }
    }

    struct ListingTile: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 140)

                Text("Modern Apartment")
                    .font(.headline)

                Text("$2,500 • 2 Bed • City Center")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
        }
    }

    // -------------------------------------------------------------
    // MARK: CUSTOM TAB BAR
    // -------------------------------------------------------------
    struct CustomTabBar: View {
        @Binding var selectedTab: String

        private let tabs = [
            ("Search", "magnifyingglass"),
            ("Messages", "message.fill"),
            ("Favourites", "heart.fill"),
            ("Profile", "person.fill")
        ]

        var body: some View {
            HStack {
                ForEach(tabs, id: \.0) { item in
                    Button {
                        selectedTab = item.0
                    } label: {
                        VStack {
                            Image(systemName: item.1)
                                .font(.system(size: 22))
                            Text(item.0)
                                .font(.caption2)
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(selectedTab == item.0 ? .blue : .gray)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
            .background(.white)
            .shadow(color: Color.black.opacity(0.08), radius: 5, y: -2)
        }
    }
}
