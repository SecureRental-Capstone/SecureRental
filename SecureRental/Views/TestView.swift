////////
////////  TestView.swift
////////  SecureRental
////////
////////  Created by Haniya Akhtar on 2025-11-18.

// -------------------------------------------------------------
// MARK: EXPLORE VIEW (MAIN SCREEN)
// -------------------------------------------------------------
//import SwiftUI
//
//struct SecureRentalHomePage: View {
//
//    @Binding var rootView : RootView
//    @State private var showFilterCard = false
//    @State private var maxPrice: Double = 5000
//    @State private var selectedBedrooms: Int? = nil
//    @State private var showVerifiedOnly = false
//    @State private var hasWifi = false
//    @State private var hasParking = false
//    @State private var isPetFriendly = false
//    @State private var hasGym = false
//
//    @StateObject var currencyManager = CurrencyViewModel()
//    @StateObject var viewModel = RentalListingsViewModel()
//
//    @State private var selectedTab: String = "Explore"
//    @State private var showAddListing = false
//    @State private var showChatbot = false
//
//
//    var body: some View {
//        ZStack(alignment: .bottom) {
//
//            // MAIN CONTENT
//            VStack(spacing: 0) {
//                
//                NavigationLink(
//                    destination: ChatbotView(),
//                    isActive: $showChatbot
//                ) {
//                    EmptyView()
//                }
//
//                NavigationLink(
//                    destination: CreateRentalListingView(viewModel: viewModel),
//                    isActive: $showAddListing
//                ) {
//                    EmptyView()
//                }
//                
//                // HEADER
//                HStack {
//                    Spacer()
////                    AddListingButton()
//                    AddListingButton {
//                        showAddListing = true
//                    }
//                    CurrencyPickerButton(
//                        selected: $currencyManager.selectedCurrency,
//                        options: currencyManager.currencies
//                    )
//                }
//                .padding(.horizontal)
//                .padding(.top, 10)
//                .padding(.bottom, 10)
//
//                // SEARCH + FILTER ROW
//                HStack(spacing: 12) {
//                    SearchBar().environmentObject(viewModel)
//
//                    FilterButton {
//                        withAnimation { showFilterCard = true }
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.bottom, 10)
//
//                // LISTING FEED
//                ScrollView(.vertical, showsIndicators: false) {
//
//                    let filteredListings = applyLocalFilters(to: viewModel.locationListings)
//
//                    // --- LOADING ---
//                    if viewModel.isLoading {
//                        LazyVStack(spacing: 20) {
//                            ForEach(0..<6, id: \.self) { _ in
//                                SkeletonListingCardView()
//                            }
//                        }
//                        .padding(.horizontal)
//                        .padding(.vertical, 10)
//
//                        // --- EMPTY ---
//                    } else if filteredListings.isEmpty {
//
//                        VStack(spacing: 10) {
//                            Image(systemName: "tray")
//                                .font(.system(size: 40))
//                                .foregroundColor(.gray.opacity(0.7))
//
//                            Text("No listings found in your area.")
//                                .font(.headline)
//
//                            Text("Try expanding your radius or updating your location.")
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                        }
//                        .frame(maxWidth: .infinity, minHeight: 300)
//
//                        // --- SUCCESS ---
//                    } else {
//
//                        Text("\(filteredListings.count) properties found")
//                            .font(.callout)
//                            .foregroundColor(.secondary)
//                            .padding(.horizontal)
//                            .padding(.top, 20)
//
//                        LazyVStack(spacing: 20) {
//                            ForEach(filteredListings) { listing in
//                                NavigationLink {
//                                    ListingDetailView(listing: listing, vm: currencyManager)
//                                } label: {
//                                    RentalListingCardView(listing: listing, vm: currencyManager)
//                                }
//                                .buttonStyle(PlainButtonStyle())
//                            }
//                        }
//                        .padding(.vertical, 10)
//                        .padding(.bottom, 100)
//                    }
//                }
//                .environmentObject(viewModel)
//                .zIndex(0)
//
//                .overlay(alignment: .bottomTrailing) {
//                    Button(action: { showChatbot = true }) {
//                        Image(systemName: "message.fill")
//                            .font(.system(size: 24))
//                            .foregroundColor(.white)
//                            .padding()
//                            .background(Color.blue)
//                            .clipShape(Circle())
//                            .shadow(radius: 4)
//                    }
//                    .padding(.trailing, 20)
//                    .padding(.bottom, 30)  // moves it above your bottom tab bar
//                }
//                
//                // TAB BAR
//                CustomTabBar(selectedTab: $selectedTab)
//                    .zIndex(3)
//            }
//            .ignoresSafeArea(.keyboard)
//
//
//            // -------------------------------------------------------------
//            // FIX: FILTER OVERLAY MOVED OUT OF VSTACK TO PREVENT TAB BAR SHIFT
//            // -------------------------------------------------------------
//            if showFilterCard {
//                Color.black.opacity(0.25)
//                    .ignoresSafeArea()
//                    .onTapGesture {
//                        withAnimation { showFilterCard = false }
//                    }
//                    .zIndex(10)
//
//                FilterCardView(
//                    isVisible: $showFilterCard,
//                    maxPrice: maxPrice,
//                    selectedBedrooms: selectedBedrooms,
//                    showVerifiedOnly: showVerifiedOnly,
//                    hasWifi: hasWifi,
//                    hasParking: hasParking,
//                    isPetFriendly: isPetFriendly,
//                    hasGym: hasGym,
//                    applyAction: { newMax, newBeds, newVerif, newWifi, newPark, newPet, newGym in
//                        maxPrice = newMax
//                        selectedBedrooms = newBeds
//                        showVerifiedOnly = newVerif
//                        hasWifi = newWifi
//                        hasParking = newPark
//                        isPetFriendly = newPet
//                        hasGym = newGym
//                    },
//                    resetAction: {
//                        maxPrice = 5000
//                        selectedBedrooms = nil
//                        showVerifiedOnly = false
//                        hasWifi = false
//                        hasParking = false
//                        isPetFriendly = false
//                        hasGym = false
//                    }
//                )
//                .transition(.move(edge: .bottom).combined(with: .opacity))
//                .zIndex(11)
//            }
//            // -------------------------------------------------------------
//        }
//    }
//
//    // -------------------------------------------------------------
//    // MARK: SEARCH BAR
//    // -------------------------------------------------------------
//
////    struct SearchBar: View {
////        @State private var text = ""
////
////        var body: some View {
////            HStack {
////                Image(systemName: "magnifyingglass")
////                TextField("Search rentals...", text: $text)
////            }
////            .padding(10)
////            .background(Color(.systemGray6))
////            .cornerRadius(10)
////        }
////    }
//    
//    struct SearchBar: View {
//        @State private var text = ""
//        @EnvironmentObject var viewModel: RentalListingsViewModel
//
//        var body: some View {
//            HStack {
//                Image(systemName: "magnifyingglass")
//                TextField("Search rentals...", text: $text)
//                    .onChange(of: text) { newValue in
//                        viewModel.filterListingsNew(
//                            searchTerm: newValue,
//                            amenities: [] // or pass real selected amenities
//                        )
//                    }
//            }
//            .padding(10)
//            .background(Color(.systemGray6))
//            .cornerRadius(10)
//        }
//    }
//
//
//    // -------------------------------------------------------------
//    // MARK: FILTER BUTTON
//    // -------------------------------------------------------------
//
//    struct FilterButton: View {
//        let action: () -> Void
//
//        var body: some View {
//            Button(action: action) {
//                Image(systemName: "slider.horizontal.3")
//                    .font(.system(size: 20))
//                    .padding(10)
//                    .background(Color(.systemGray6))
//                    .cornerRadius(10)
//            }
//        }
//    }
//
//    func applyLocalFilters(to listings: [Listing]) -> [Listing] {
//        var filtered = listings
//
//        let converted = listings.filter { listing in
//            let cleaned = listing.price
//                .replacingOccurrences(of: ",", with: "")
//                .replacingOccurrences(of: "$", with: "")
//                .trimmingCharacters(in: .whitespaces)
//            return Double(cleaned) ?? 0 <= maxPrice
//        }
//        filtered = converted
//
//        if let beds = selectedBedrooms {
//            if beds == 3 {
//                filtered = filtered.filter { $0.numberOfBedrooms >= 3 }
//            } else {
//                filtered = filtered.filter { $0.numberOfBedrooms == beds }
//            }
//        }
//
//        if showVerifiedOnly {
//            filtered = filtered.filter { $0.isAvailable }
//        }
//
//        return filtered
//    }
//
//    func resetFilters() {
//        maxPrice = 5000
//        selectedBedrooms = nil
//        showVerifiedOnly = false
//    }
//
//    struct CurrencySelectorButton: View {
//        @State private var currency = "USD"
//
//        var body: some View {
//            Menu {
//                Button("USD") { currency = "USD" }
//                Button("EUR") { currency = "EUR" }
//                Button("GBP") { currency = "GBP" }
//            } label: {
//                HStack {
//                    Text(currency)
//                    Image(systemName: "chevron.down")
//                }
//                .padding(8)
//                .background(Color(.systemGray6))
//                .cornerRadius(8)
//            }
//        }
//    }
//
////    struct AddListingButton: View {
////        var body: some View {
////            Button(action: {}) {
////                Image(systemName: "plus.square.on.square.fill")
////                    .font(.system(size: 26))
////            }
////        }
////    }
//    
//    struct AddListingButton: View {
//        let action: () -> Void
//        
//        var body: some View {
//            Button(action: action) {
//                Image(systemName: "plus.square.on.square.fill")
//                    .font(.system(size: 26))
//            }
//        }
//    }
//
//
//    struct ListingTile: View {
//        var body: some View {
//            VStack(alignment: .leading, spacing: 6) {
//                RoundedRectangle(cornerRadius: 12)
//                    .fill(Color.gray.opacity(0.3))
//                    .frame(height: 140)
//
//                Text("Modern Apartment")
//                    .font(.headline)
//
//                Text("$2,500 • 2 Bed • City Center")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//            }
//            .padding(.horizontal)
//        }
//    }
//
//    // -------------------------------------------------------------
//    // MARK: CUSTOM TAB BAR
//    // -------------------------------------------------------------
//
//    struct CustomTabBar: View {
//        @Binding var selectedTab: String
//
//        private let tabs = [
//            ("Search", "magnifyingglass"),
//            ("Messages", "message.fill"),
//            ("Favourites", "heart.fill"),
//            ("Profile", "person.fill")
//        ]
//
//        var body: some View {
//            HStack {
//                ForEach(tabs, id: \.0) { item in
//                    Button {
//                        selectedTab = item.0
//                    } label: {
//                        VStack {
//                            Image(systemName: item.1)
//                                .font(.system(size: 22))
//                            Text(item.0)
//                                .font(.caption2)
//                        }
//                        .frame(maxWidth: .infinity)
//                        .foregroundColor(selectedTab == item.0 ? .blue : .gray)
//                    }
//                }
//            }
//            .padding(.horizontal, 8)
//            .padding(.vertical, 12)
//            .background(.white)
//            .shadow(color: Color.black.opacity(0.08), radius: 5, y: -2)
//        }
//    }
//}

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

                // HEADER
//                HStack {
//                    Spacer()
//                    AddListingButton {
//                        showAddListing = true
//                    }
//                    CurrencyPickerButton(
//                        selected: $currencyManager.selectedCurrency,
//                        options: currencyManager.currencies
//                    )
//                }
//                .padding(.horizontal)
//                .padding(.top, 10)
//                .padding(.bottom, 10)

                // --- MAIN TAB CONTENT (switches by selectedTab) ---
                Group {
                    switch selectedTab {
                    case "Search":
                        exploreContent
                    case "Messages":
                        MessageView()
                    case "Favourites":
                        FavouriteListingsView(viewModel: viewModel).environmentObject(fireDBHelper)
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
                                ListingDetailView(listing: listing, vm: currencyManager)
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
//            .overlay(alignment: .bottomTrailing) {
//                Button(action: { showChatbot = true }) {
//                    
//                    Image("Chatbot")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 68, height: 66)
//                        .padding(14)
//                        .background(Color.white)
//                        .clipShape(Circle())
//                        .shadow(color: .black.opacity(0.3), radius: 6, y: 3)
//                    
//                        // ⭐ Floating animation
//                        .offset(y: float ? -8 : 0)        // moves up + down softly
//                        .animation(
//                            Animation.easeInOut(duration: 2.0)
//                                .repeatForever(autoreverses: true),
//                            value: float
//                        )
//                        .onAppear { float = true }
//                    
//                }
//                .padding(.trailing, 16)
//                .padding(.bottom, 5)
//            }
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
//                        Image(systemName: "message.fill")
//                                         .font(.system(size: 24))
//                                                .foregroundColor(.white)
//                                .padding()
//                            .background(Color.blue)
//                          .clipShape(Circle())
//                                                     .shadow(radius: 4)
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

//            .overlay(alignment: .bottomTrailing) {
//                
//                ZStack(alignment: .bottomTrailing) {
//                    
//                        // ✨ Tooltip bubble
//                    if showTooltip {
//                        Text("Ask a question")
//                            .font(.caption)
//                            .padding(.horizontal, 10)
//                            .padding(.vertical, 6)
//                            .background(Color.black.opacity(0.8))
//                            .foregroundColor(.white)
//                            .cornerRadius(8)
//                            .offset(y: -100)  // position above chatbot
//                            .transition(.opacity.combined(with: .move(edge: .bottom)))
//                    }
//                    
//                        // 🤖 Chatbot Button
//                    Button(action: {
//                        showChatbot = true
//                    }) {
//                        Image("Chatbot")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 68, height: 66)
//                            .padding(14)
//                            .background(Color.white.opacity(0.95))
//
//                            .clipShape(Circle())
//                            .shadow(color: Color.blue.opacity(0.25), radius: 12, x: 0, y: 6)
//
//                            .overlay(
//                                Circle()
//                                    .stroke(Color(.systemGray5), lineWidth: 2)
//                                    .blur(radius: 4)
//                            )
//                        
//                            // ⭐ Floating animation
//                            .offset(y: float ? -8 : 0)
//                            .animation(
//                                Animation.easeInOut(duration: 2.0)
//                                    .repeatForever(autoreverses: true),
//                                value: float
//                            )
//                            .onAppear { float = true }
//                        
//                    }
//                        // 👇 long press triggers tooltip
//                    .simultaneousGesture(
//                        LongPressGesture(minimumDuration: 0.25)
//                            .onEnded { _ in
//                                withAnimation {
//                                    showTooltip = true
//                                }
//                                    // Hide automatically after 1.5 sec
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                                    withAnimation {
//                                        showTooltip = false
//                                    }
//                                }
//                            }
//                    )
//                    .padding(.trailing, 10)
//                    .padding(.bottom, 5)
//                }
//            }


//            .overlay(alignment: .bottomTrailing) {
//                Button(action: { showChatbot = true }) {
////                    Image(systemName: "message.fill")
//                    Image("Chatbot")   // feels like AI, not messaging
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 68, height: 66)
//                        .padding(14)
//                        .background(Color.white)
//                        .clipShape(Circle())
//                        .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
//                        .padding(.trailing, 16)
//                        .padding(.bottom, 5)
////                        .resizable()
////                        .renderingMode(.original)
////                        .scaledToFit()
////                        .frame(width: 75, height: 75)   // larger for testing
//////                        .padding(5)
//////                        .background(Color.white)
////                        .clipShape(Circle())
////                        .shadow(radius: 4)
//                }
//                .padding(.trailing, 5)
//                .padding(.bottom, 5) // adjust up/down
//            }

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

//    func applyLocalFilters(to listings: [Listing]) -> [Listing] {
//        var filtered = listings
//
//        let numberOnly = listing.price
//            .components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted)
//            .joined()
//        
//        let priceValue = Double(numberOnly) ?? 0
//        return priceValue <= maxPrice
//
//        }
//        filtered = converted
//
//        if let beds = selectedBedrooms {
//            if beds == 3 {
//                filtered = filtered.filter { $0.numberOfBedrooms >= 3 }
//            } else {
//                filtered = filtered.filter { $0.numberOfBedrooms == beds }
//            }
//        }
//
//        if showVerifiedOnly {
//            filtered = filtered.filter { $0.isAvailable }
//        }
//
//        return filtered
//    }
    func applyLocalFilters(to listings: [Listing]) -> [Listing] {
        print("📦 LOADED LISTINGS COUNT:", viewModel.locationListings.count)
        for l in viewModel.locationListings {
            print(" -", l.price)
        }

        var filtered = listings
        
            // PRICE FILTER (with debug)
        filtered = filtered.filter { listing in
            let cleaned = listing.price
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .components(separatedBy: CharacterSet(charactersIn: "0123456789").inverted)
                .joined()
            
            let priceValue = Double(cleaned) ?? 0
            
            print("🔎 PRICE FILTER -> id:\(listing.id) raw:\(listing.price) cleaned:\(cleaned) priceValue:\(priceValue)   maxPrice:\(maxPrice)")
            
            return priceValue <= maxPrice
        }
        
            // BEDROOM FILTER
        if let beds = selectedBedrooms {
            filtered = filtered.filter { listing in
                let pass: Bool
                if beds == 3 {
                    pass = listing.numberOfBedrooms >= 3
                } else {
                    pass = listing.numberOfBedrooms == beds
                }
                print("🛏 BED FILTER -> id:\(listing.id) beds:\(listing.numberOfBedrooms) selected:\(beds) pass:\(pass)")
                return pass
            }
        }
        
            // VERIFIED FILTER
        if showVerifiedOnly {
            filtered = filtered.filter { listing in
                print("✅ VERIFIED FILTER -> id:\(listing.id) isAvailable:\(listing.isAvailable)")
                return listing.isAvailable
            }
        }
        
        print("✅ FINAL FILTERED COUNT: \(filtered.count) (maxPrice=\(maxPrice), selectedBedrooms=\(String(describing: selectedBedrooms)), verifiedOnly=\(showVerifiedOnly))")
        
        return filtered
    }




    func resetFilters() {
        maxPrice = 5000
        selectedBedrooms = nil
        showVerifiedOnly = false
    }

    struct CurrencySelectorButton: View {
        @State private var currency = "USD"

        var body: some View {
            Menu {
                Button("USD") { currency = "USD" }
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


// -------------------------------------------------------------
// MARK: Placeholder views for tabs (replace with your own)
/// These are included so the file compiles without needing other files.
//struct SearchView: View { var body: some View { VStack { Text("Search View").font(.title) } } }
//struct ChatView: View { var body: some View { VStack { Text("Chat View").font(.title) } } }
//struct FavouritesView: View { var body: some View { VStack { Text("Favourites View").font(.title) } } }
//struct ProfileView: View { var body: some View { VStack { Text("Profile View").font(.title) } } }

// Placeholder ChatbotView and CreateRentalListingView so NavigationLinks compile
//struct ChatbotView: View { var body: some View { Text("Chatbot").font(.largeTitle) } }
//struct CreateRentalListingView: View {
//    let viewModel: RentalListingsViewModel
//    var body: some View { Text("Create Listing").font(.largeTitle) }
//}
