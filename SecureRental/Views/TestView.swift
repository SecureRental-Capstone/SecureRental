////////
////////  TestView.swift
////////  SecureRental
////////
////////  Created by Haniya Akhtar on 2025-11-18.
////////
//
//import SwiftUI
//import FirebaseAuth
//
//struct SecureRentalHomePage: View {
//    
//    @EnvironmentObject var dbHelper: FireDBHelper
//    
//    @State private var showMessageView = false
//    @State private var showCreateListingView = false
//    
//    @StateObject var viewModel = RentalListingsViewModel()
//    @StateObject var currencyManager = CurrencyViewModel()
//    
//    @State private var searchText: String = ""
//    
//    // ⭐️ String-based tab selection (keep the old logic)
//    @State private var selectedTab: String = "Search"
//    @Binding var rootView: RootView
//
//    // Location workflow
//    @State private var shouldOpenLocationSheetAfterConsent = false
//    @State private var isConsentFlowLoading = false
//    
//    // ---------------------------
//    // MARK: - FILTER CARD STATE
//    // ---------------------------
//    @State private var showFilterCard: Bool = false
////    @State private var priceRange: ClosedRange<Double> = 600...5000
//    @State private var maxPrice: Double = 5000
//    @State private var selectedBedrooms: Int? = nil
//    @State private var showVerifiedOnly: Bool = false
//    
//    @State private var hasWifi: Bool = false      // Defaults to false (not required)
//    @State private var hasParking: Bool = false   // Defaults to false
//    @State private var isPetFriendly: Bool = false // Defaults to false
//    @State private var hasGym: Bool = false       // Defaults to false
//    
//    
//    var body: some View {
//        ZStack(alignment: .bottom) {
//
//            // -------------------------------------------------------------------
//            // MARK: - STRING-BASED TAB SWITCH (old logic preserved)
//            // -------------------------------------------------------------------
//            switch selectedTab {
//
//            // =====================================================
//            // MARK: ================= HOME / SEARCH ================
//            // =====================================================
//            case "Search":
//                NavigationView {
//                    ZStack {
//                        
//                        // Background gradient
//                        LinearGradient(
//                            colors: [
//                                Color.blue.opacity(0.06),
//                                Color(.systemBackground)
//                            ],
//                            startPoint: .top,
//                            endPoint: .bottom
//                        )
//                        .ignoresSafeArea()
//                        
//                        ScrollView {
//                            VStack(alignment: .leading, spacing: 0) {
//
//                                // -----------------------------------------------------
//                                // MARK: - HEADER
//                                // -----------------------------------------------------
//                                HStack {
//                                    Text("SecureRental")
//                                        .font(.title3.weight(.bold))
//                                        .foregroundColor(.blue)
//                                    
//                                    Spacer()
//                                    
//                                    Button(action: {
//                                        showCreateListingView = true
//                                    }) {
//                                        Image(systemName: "plus.square.on.square")
//                                            .font(.title2)
//                                            .foregroundColor(.blue)
//                                    }
//                                    
//                                    if !currencyManager.currencies.isEmpty {
//                                        CurrencyPickerButton(
//                                            selected: $currencyManager.selectedCurrency,
//                                            options: currencyManager.currencies
//                                        )
//                                    }
//                                }
//                                .padding(.horizontal)
//                                .padding(.top, 10)
//                                
//                                // -----------------------------------------------------
//                                // MARK: - SEARCH BAR
//                                // -----------------------------------------------------
//                                HStack(spacing: 8) {
//                                    HStack {
//                                        Image(systemName: "magnifyingglass")
//                                            .foregroundColor(.gray)
//                                        TextField("Search location or university...", text: $searchText)
//                                    }
//                                    .padding(.vertical, 12)
//                                    .padding(.horizontal, 15)
//                                    .background(Color(.systemGray6))
//                                    .cornerRadius(10)
//                                    
//                                    Button {
//                                        withAnimation {
//                                            showFilterCard = true
//                                        }
//                                    } label: {
//                                        Image(systemName: "slider.horizontal.3")
//                                            .font(.title3)
//                                            .foregroundColor(.primary)
//                                            .padding(10)
//                                            .background(Color(.systemGray6))
//                                            .cornerRadius(10)
//                                    }
//                                }
//                                .padding(.horizontal)
//                                .padding(.top, 8)
//                                
//                                // -----------------------------------------------------
//                                // MARK: - LISTINGS SECTION
//                                // -----------------------------------------------------
//
//                                let filteredListings = applyLocalFilters(to: viewModel.locationListings)
//
//                                if viewModel.isLoading {
//                                    LazyVStack(spacing: 20) {
//                                        ForEach(0..<6, id: \.self) { _ in
//                                            SkeletonListingCardView()
//                                        }
//                                    }
//                                    .padding(.horizontal)
//                                    .padding(.vertical, 10)
//                                } else if filteredListings.isEmpty {
//
//                                    VStack(spacing: 10) {
//                                        Image(systemName: "tray")
//                                            .font(.system(size: 40))
//                                            .foregroundColor(.gray.opacity(0.7))
//
//                                        Text("No listings found in your area.")
//                                            .font(.headline)
//
//                                        Text("Try expanding your radius or updating your location.")
//                                            .font(.caption)
//                                            .foregroundColor(.secondary)
//                                    }
//                                    .frame(maxWidth: .infinity, minHeight: 300)
//
//                                } else {
//
//                                    Text("\(filteredListings.count) properties found")
//                                        .font(.callout)
//                                        .foregroundColor(.secondary)
//                                        .padding(.horizontal)
//                                        .padding(.top, 20)
//
//                                    LazyVStack(spacing: 20) {
//                                        ForEach(filteredListings) { listing in
//                                            NavigationLink {
//                                                ListingDetailView(listing: listing, vm: currencyManager)
//                                            } label: {
//                                                RentalListingCardView(listing: listing, vm: currencyManager)
//                                            }
//                                            .buttonStyle(PlainButtonStyle())
//                                        }
//                                    }
//                                    .padding(.vertical, 10)
//                                    .padding(.bottom, 100)
//                                }
//                            }
//                        }
//
//                        // -----------------------------------------------------
//                        // MARK: - LOCATION CONSENT LOADING OVERLAY
//                        // -----------------------------------------------------
//                        if isConsentFlowLoading {
//                            Color.black.opacity(0.05).ignoresSafeArea()
//                            
//                            ProgressView("Updating location…")
//                                .padding()
//                                .background(.ultraThinMaterial)
//                                .cornerRadius(12)
//                        }
//                        
//                        // -----------------------------------------------------
//                        // MARK: - FILTER CARD OVERLAY
//                        // -----------------------------------------------------
//                        if showFilterCard {
//                            Color.black.opacity(0.25)
//                                .ignoresSafeArea()
//                                .onTapGesture {
//                                    withAnimation { showFilterCard = false }
//                                }
//                    
//                            FilterCardView(
//                                isVisible: $showFilterCard,
//                                maxPrice: maxPrice,
//                                selectedBedrooms: selectedBedrooms,
//                                showVerifiedOnly: showVerifiedOnly,
//                                hasWifi: hasWifi,
//                                hasParking: hasParking,
//                                isPetFriendly: isPetFriendly,
//                                hasGym: hasGym,
//                                applyAction: { newMaxPrice, newBedrooms, newVerifiedOnly, newHasWifi, newHasParking, newIsPetFriendly, newHasGym in
//                                    maxPrice = newMaxPrice
//                                    selectedBedrooms = newBedrooms
//                                    showVerifiedOnly = newVerifiedOnly
//                                    hasWifi = newHasWifi
//                                    hasParking = newHasParking
//                                    isPetFriendly = newIsPetFriendly
//                                    hasGym = newHasGym
//                                },
//                                resetAction: {
//                                    maxPrice = 5000
//                                    selectedBedrooms = nil
//                                    showVerifiedOnly = false
//                                    hasWifi = false
//                                    hasParking = false
//                                    isPetFriendly = false
//                                    hasGym = false
//                                }
//                            )
//                            .transition(.move(edge: .bottom).combined(with: .opacity))
//                            .animation(.easeInOut, value: showFilterCard)
//                        }
//                    }
//                    .navigationBarHidden(true)
//                    .onAppear {
//                        Task {
//                            if let uid = Auth.auth().currentUser?.uid,
//                               let fetchedUser = await dbHelper.getUser(byUID: uid) {
//                                
//                                dbHelper.currentUser = fetchedUser
//                                
//                                if let lat = fetchedUser.latitude,
//                                   let lon = fetchedUser.longitude {
//                                    await viewModel.updateCityFromStoredCoordinates(
//                                        latitude: lat,
//                                        longitude: lon
//                                    )
//                                }
//                            }
//                            await viewModel.loadHomePageListings()
//                        }
//                    }
//                }
//
//            // =====================================================
//            // MARK: ================= MESSAGES =====================
//            // =====================================================
//            case "Messages":
//                NavigationView {
//                    MyChatsView()
//                }
//
//            // =====================================================
//            // MARK: ================= FAVOURITES ==================
//            // =====================================================
//            case "Favourites":
//                NavigationView {
//                    FavouriteListingsView(viewModel: viewModel)
//                }
//
//            // =====================================================
//            // MARK: ================= PROFILE ======================
//            // =====================================================
//            case "Profile":
//                NavigationView {
//                    ProfileView(rootView: $rootView)
//                    
//                }
//
//            default:
//                EmptyView()
//            }
//            // MARK: - Floating Chatbot Button
//            VStack {
//                Spacer()
//                HStack {
//                    Spacer()
//                    Button(action: {
//                        showMessageView = true
//                    }) {
//                        Image(systemName: "bubble.right.fill")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 24, height: 24)
//                            .foregroundColor(.white)
//                            .padding()
//                            .background(Color.hunterGreen)
//                            .clipShape(Circle())
//                            .shadow(radius: 8)
//                    }
//                    .padding(.bottom, 100)
//                    .padding(.trailing, 18)
//                }
//            }
//            // -------------------------------------------------------------------
//            // MARK: - Custom Bottom Tab Bar (STRING-BASED SELECTION)
//            // -------------------------------------------------------------------
//            CustomTabBar(selectedTab: $selectedTab)
//        }
//
//        // -------------------------------------------------------------------
//        // MARK: - Chatbot / Create Listing / Update Location Sheets
//        // -------------------------------------------------------------------
////        .sheet(isPresented: $showMessageView) {
////            ChatbotView()
////        }
//        .sheet(isPresented: $showCreateListingView) {
//            CreateRentalListingView(viewModel: viewModel)
//        }
//        .sheet(isPresented: $viewModel.showUpdateLocationSheet) {
//            UpdateLocationView(viewModel: viewModel)
//        }
//
//        // -------------------------------------------------------------------
//        // MARK: - Location Consent Alert
//        // -------------------------------------------------------------------
//        .alert("Allow SecureRental to access your location?", isPresented: $viewModel.showLocationConsentAlert) {
//            Button("No") {
//                Task {
//                    await viewModel.handleLocationConsentResponse(granted: false)
//                    isConsentFlowLoading = false
//                    shouldOpenLocationSheetAfterConsent = false
//                }
//            }
//            Button("Yes") {
//                Task {
//                    await viewModel.handleLocationConsentResponse(granted: true)
//                    if shouldOpenLocationSheetAfterConsent {
//                        viewModel.showUpdateLocationSheet = true
//                    }
//                    isConsentFlowLoading = false
//                    shouldOpenLocationSheetAfterConsent = false
//                }
//            }
//        }
//    }
//
//    func applyLocalFilters(to listings: [Listing]) -> [Listing] {
//        var filtered = listings
//
//        // PRICE RANGE FILTER (String → Double conversion)
//        filtered = filtered.filter { listing in
//            // Clean price string: remove commas, $, spaces
//            let cleaned = listing.price
//                .replacingOccurrences(of: ",", with: "")
//                .replacingOccurrences(of: "$", with: "")
//                .trimmingCharacters(in: .whitespacesAndNewlines)
//
//            // Convert to Double
//            guard let price = Double(cleaned) else {
//                return false // skip invalid or non-numeric prices
//            }
//
////            return price >= priceRange.lowerBound &&
////                   price <= priceRange.upperBound
//            return price <= maxPrice
//
//        }
//
//        // BEDROOMS FILTER
//        if let beds = selectedBedrooms {
//            if beds == 3 {
//                filtered = filtered.filter { $0.numberOfBedrooms >= 3 }
//            } else {
//                filtered = filtered.filter { $0.numberOfBedrooms == beds }
//            }
//        }
//
//        // VERIFIED FILTER
//        if showVerifiedOnly {
//            filtered = filtered.filter { $0.isAvailable }   // ← update based on your actual field
//        }
//
//        return filtered
//    }
//    
//    func resetFilters() {
////        priceRange = 600...5000
//        maxPrice <= maxPrice
//        selectedBedrooms = nil
//        showVerifiedOnly = false
//    }
//}
//
//struct SinglePriceSlider: View {
//    @Binding var maxPrice: Double
//    let bounds: ClosedRange<Double>
//    let step: Double
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Max Price: \(Int(maxPrice))")
//                .font(.headline)
//
//            Slider(
//                value: $maxPrice,
//                in: bounds,
//                step: step
//            )
//        }
//    }
//}

//import SwiftUI
//import FirebaseAuth
//
//struct SecureRentalHomePage: View {
//    
//    @EnvironmentObject var dbHelper: FireDBHelper
//    
//    @State private var showMessageView = false
//    @State private var showCreateListingView = false
//    
//    @StateObject var viewModel = RentalListingsViewModel()
//    @StateObject var currencyManager = CurrencyViewModel()
//    
//    @State private var searchText: String = ""
//    
//    // ⭐️ String-based tab selection (keep the old logic)
//    @State private var selectedTab: String = "Search"
//    @Binding var rootView: RootView
//
//    // Location workflow
//    @State private var shouldOpenLocationSheetAfterConsent = false
//    @State private var isConsentFlowLoading = false
//    
//    // Filters
//    @State private var showFilterCard: Bool = false
//    @State private var maxPrice: Double = 5000
//    @State private var selectedBedrooms: Int? = nil
//    @State private var showVerifiedOnly: Bool = false
//    
//    @State private var hasWifi: Bool = false
//    @State private var hasParking: Bool = false
//    @State private var isPetFriendly: Bool = false
//    @State private var hasGym: Bool = false
//    
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            
//            switch selectedTab {
//                
//            // MARK: - SEARCH TAB
//            case "Search":
//                NavigationView {
//                    ZStack {
//
//                        LinearGradient(
//                            colors: [
//                                Color.blue.opacity(0.06),
//                                Color(.systemBackground)
//                            ],
//                            startPoint: .top,
//                            endPoint: .bottom
//                        )
//                        .ignoresSafeArea()
//
//                        ScrollView {
//                            VStack(alignment: .leading, spacing: 0) {
//
//                                // HEADER
//                                HStack {
//                                    Text("SecureRental")
//                                        .font(.title3.weight(.bold))
//                                        .foregroundColor(.blue)
//
//                                    Spacer()
//
//                                    Button(action: {
//                                        showCreateListingView = true
//                                    }) {
//                                        Image(systemName: "plus.square.on.square")
//                                            .font(.title2)
//                                            .foregroundColor(.blue)
//                                    }
//
//                                    if !currencyManager.currencies.isEmpty {
//                                        CurrencyPickerButton(
//                                            selected: $currencyManager.selectedCurrency,
//                                            options: currencyManager.currencies
//                                        )
//                                    }
//                                }
//                                .padding(.horizontal)
//                                .padding(.top, 10)
//
//                                // SEARCH BAR
//                                HStack(spacing: 8) {
//                                    HStack {
//                                        Image(systemName: "magnifyingglass")
//                                            .foregroundColor(.gray)
//                                        TextField("Search location or university...", text: $searchText)
//                                    }
//                                    .padding(.vertical, 12)
//                                    .padding(.horizontal, 15)
//                                    .background(Color(.systemGray6))
//                                    .cornerRadius(10)
//
//                                    Button {
//                                        withAnimation {
//                                            showFilterCard = true
//                                        }
//                                    } label: {
//                                        Image(systemName: "slider.horizontal.3")
//                                            .font(.title3)
//                                            .foregroundColor(.primary)
//                                            .padding(10)
//                                            .background(Color(.systemGray6))
//                                            .cornerRadius(10)
//                                    }
//                                }
//                                .padding(.horizontal)
//                                .padding(.top, 8)
//
//                                // LISTINGS
//                                let filteredListings = applyLocalFilters(to: viewModel.locationListings)
//
//                                if viewModel.isLoading {
//                                    LazyVStack(spacing: 20) {
//                                        ForEach(0..<6, id: \.self) { _ in
//                                            SkeletonListingCardView()
//                                        }
//                                    }
//                                    .padding(.horizontal)
//                                    .padding(.vertical, 10)
//
//                                } else if filteredListings.isEmpty {
//
//                                    VStack(spacing: 10) {
//                                        Image(systemName: "tray")
//                                            .font(.system(size: 40))
//                                            .foregroundColor(.gray.opacity(0.7))
//
//                                        Text("No listings found in your area.")
//                                            .font(.headline)
//
//                                        Text("Try expanding your radius or updating your location.")
//                                            .font(.caption)
//                                            .foregroundColor(.secondary)
//                                    }
//                                    .frame(maxWidth: .infinity, minHeight: 300)
//
//                                } else {
//
//                                    Text("\(filteredListings.count) properties found")
//                                        .font(.callout)
//                                        .foregroundColor(.secondary)
//                                        .padding(.horizontal)
//                                        .padding(.top, 20)
//
//                                    LazyVStack(spacing: 20) {
//                                        ForEach(filteredListings) { listing in
//                                            NavigationLink {
//                                                ListingDetailView(listing: listing, vm: currencyManager)
//                                            } label: {
//                                                RentalListingCardView(listing: listing, vm: currencyManager)
//                                            }
//                                            .buttonStyle(PlainButtonStyle())
//                                        }
//                                    }
//                                    .padding(.vertical, 10)
//                                    .padding(.bottom, 100)
//                                }
//                            }
//                        }
//                        .zIndex(2)   // ⭐️ SEARCH + FILTER ARE TAPPABLE NOW
//
//                        // LOADING OVERLAY
//                        if isConsentFlowLoading {
//                            Color.black.opacity(0.05).ignoresSafeArea()
//
//                            ProgressView("Updating location…")
//                                .padding()
//                                .background(.ultraThinMaterial)
//                                .cornerRadius(12)
//                        }
//
//                        // FILTER OVERLAY
//                        if showFilterCard {
//                            Color.black.opacity(0.25)
//                                .ignoresSafeArea()
//                                .onTapGesture {
//                                    withAnimation { showFilterCard = false }
//                                }
//
//                            FilterCardView(
//                                isVisible: $showFilterCard,
//                                maxPrice: maxPrice,
//                                selectedBedrooms: selectedBedrooms,
//                                showVerifiedOnly: showVerifiedOnly,
//                                hasWifi: hasWifi,
//                                hasParking: hasParking,
//                                isPetFriendly: isPetFriendly,
//                                hasGym: hasGym,
//                                applyAction: { newMaxPrice, newBedrooms, newVerifiedOnly, newHasWifi, newHasParking, newIsPetFriendly, newHasGym in
//                                    maxPrice = newMaxPrice
//                                    selectedBedrooms = newBedrooms
//                                    showVerifiedOnly = newVerifiedOnly
//                                    hasWifi = newHasWifi
//                                    hasParking = newHasParking
//                                    isPetFriendly = newIsPetFriendly
//                                    hasGym = newHasGym
//                                },
//                                resetAction: {
//                                    maxPrice = 5000
//                                    selectedBedrooms = nil
//                                    showVerifiedOnly = false
//                                    hasWifi = false
//                                    hasParking = false
//                                    isPetFriendly = false
//                                    hasGym = false
//                                }
//                            )
//                            .transition(.move(edge: .bottom).combined(with: .opacity))
//                        }
//                    }
//                    .navigationBarHidden(true)
//                    .onAppear {
//                        Task {
//                            if let uid = Auth.auth().currentUser?.uid,
//                               let fetchedUser = await dbHelper.getUser(byUID: uid) {
//                                
//                                dbHelper.currentUser = fetchedUser
//                                
//                                if let lat = fetchedUser.latitude,
//                                   let lon = fetchedUser.longitude {
//                                    await viewModel.updateCityFromStoredCoordinates(
//                                        latitude: lat,
//                                        longitude: lon
//                                    )
//                                }
//                            }
//                            await viewModel.loadHomePageListings()
//                        }
//                    }
//                }
//
//            // MESSAGES
//            case "Messages":
//                NavigationView {
//                    MyChatsView()
//                }
//
//            // FAVOURITES
//            case "Favourites":
//                NavigationView {
//                    FavouriteListingsView(viewModel: viewModel)
//                }
//
//            // PROFILE
//            case "Profile":
//                NavigationView {
//                    ProfileView(rootView: $rootView)
//                }
//
//            default:
//                EmptyView()
//            }
//
//            // CHATBOT FLOATING BUTTON
//            VStack {
//                Spacer()
//                HStack {
//                    Spacer()
//                    Button(action: {
//                        showMessageView = true
//                    }) {
//                        Image(systemName: "bubble.right.fill")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 24, height: 24)
//                            .foregroundColor(.white)
//                            .padding()
//                            .background(Color.hunterGreen)
//                            .clipShape(Circle())
//                            .shadow(radius: 8)
//                    }
//                    .padding(.bottom, 100)
//                    .padding(.trailing, 18)
//                }
//            }
//
//            // CUSTOM TAB BAR
//            CustomTabBar(selectedTab: $selectedTab)
//                .zIndex(1)   // ⭐️ BELOW UI INTERACTIONS
//        }
//
//        // SHEETS
//        .sheet(isPresented: $showCreateListingView) {
//            CreateRentalListingView(viewModel: viewModel)
//        }
//        .sheet(isPresented: $viewModel.showUpdateLocationSheet) {
//            UpdateLocationView(viewModel: viewModel)
//        }
//
//        .alert("Allow SecureRental to access your location?", isPresented: $viewModel.showLocationConsentAlert) {
//            Button("No") {
//                Task {
//                    await viewModel.handleLocationConsentResponse(granted: false)
//                    isConsentFlowLoading = false
//                    shouldOpenLocationSheetAfterConsent = false
//                }
//            }
//            Button("Yes") {
//                Task {
//                    await viewModel.handleLocationConsentResponse(granted: true)
//                    if shouldOpenLocationSheetAfterConsent {
//                        viewModel.showUpdateLocationSheet = true
//                    }
//                    isConsentFlowLoading = false
//                    shouldOpenLocationSheetAfterConsent = false
//                }
//            }
//        }
//    }
//
//    // FILTER LOGIC
//    func applyLocalFilters(to listings: [Listing]) -> [Listing] {
//        var filtered = listings
//
//        let cleanedListings = filtered.filter { listing in
//            let cleaned = listing.price
//                .replacingOccurrences(of: ",", with: "")
//                .replacingOccurrences(of: "$", with: "")
//                .trimmingCharacters(in: .whitespacesAndNewlines)
//
//            guard let price = Double(cleaned) else { return false }
//
//            return price <= maxPrice
//        }
//
//        filtered = cleanedListings
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
//}

//BAD UI BUT WORKIN
//import SwiftUI
//
//// -------------------------------------------------------------
//// MARK: EXPLORE VIEW (MAIN SCREEN)
//// -------------------------------------------------------------
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
//
//    var body: some View {
//        ZStack(alignment: .bottom) {
//
//            // MAIN CONTENT
//            VStack(spacing: 0) {
//
//                // HEADER
//                HStack {
//                    Spacer()
//                    AddListingButton()
//                    //CurrencySelectorButton()
//                    CurrencyPickerButton(
//                        selected: $currencyManager.selectedCurrency,
//                        options: currencyManager.currencies
//                    )
//
//                }
//                .padding(.horizontal)
//                .padding(.top, 10)
//                .padding(.bottom, 10)
//
//                // SEARCH + FILTER ROW
//                HStack(spacing: 12) {
//                    SearchBar()
//                    FilterButton {
//                        withAnimation { showFilterCard = true }
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.bottom, 10)
//
//                // LISTING FEED
//                //                ScrollView(.vertical, showsIndicators: false) {
//                //                    LazyVStack(spacing: 14) {
//                //                        ForEach(0..<20) { _ in
//                //                            ListingTile()
//                //                        }
//                //                    }
//                //                    .padding(.bottom, 90) // so tab bar doesn't cover content
//                //                }
//                //            }
//                //            .zIndex(0)
//
//                ScrollView(.vertical, showsIndicators: false) {
//
//                    let filteredListings = applyLocalFilters(to: viewModel.locationListings)
//
//                    // --- LOADING STATE ---
//                    if viewModel.isLoading {
//
//                        LazyVStack(spacing: 20) {
//                            ForEach(0..<6, id: \.self) { _ in
//                                SkeletonListingCardView()
//                            }
//                        }
//                        .padding(.horizontal)
//                        .padding(.vertical, 10)
//
//                        // --- EMPTY STATE ---
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
//                        // --- SUCCESS STATE ---
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
//                        .padding(.bottom, 100) // so tab bar doesn’t cover content
//                    }
//                }
//                .environmentObject(viewModel)
//                .zIndex(0)
//
//
//                // TAB BAR
//                CustomTabBar(selectedTab: $selectedTab)
//                    .zIndex(3)
//
//                // FILTER OVERLAY + CARD
//                if showFilterCard {
//                    Color.black.opacity(0.25)
//                        .ignoresSafeArea()
//                        .onTapGesture {
//                            withAnimation { showFilterCard = false }
//                        }
//                        .zIndex(10)
//
//                    FilterCardView(
//                        isVisible: $showFilterCard,
//                        maxPrice: maxPrice,
//                        selectedBedrooms: selectedBedrooms,
//                        showVerifiedOnly: showVerifiedOnly,
//                        hasWifi: hasWifi,
//                        hasParking: hasParking,
//                        isPetFriendly: isPetFriendly,
//                        hasGym: hasGym,
//                        applyAction: { newMax, newBeds, newVerif, newWifi, newPark, newPet, newGym in
//                            maxPrice = newMax
//                            selectedBedrooms = newBeds
//                            showVerifiedOnly = newVerif
//                            hasWifi = newWifi
//                            hasParking = newPark
//                            isPetFriendly = newPet
//                            hasGym = newGym
//                        },
//                        resetAction: {
//                            maxPrice = 5000
//                            selectedBedrooms = nil
//                            showVerifiedOnly = false
//                            hasWifi = false
//                            hasParking = false
//                            isPetFriendly = false
//                            hasGym = false
//                        }
//                    )
//                    .transition(.move(edge: .bottom).combined(with: .opacity))
//                    .zIndex(11)
//                }
//            }
//            .ignoresSafeArea(.keyboard)
//        }
//    }
//
//
//    // -------------------------------------------------------------
//    // MARK: SEARCH BAR
//    // -------------------------------------------------------------
//
//    struct SearchBar: View {
//        @State private var text = ""
//
//        var body: some View {
//            HStack {
//                Image(systemName: "magnifyingglass")
//                TextField("Search rentals...", text: $text)
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
//        // PRICE RANGE FILTER (String → Double conversion)
//        filtered = filtered.filter { listing in
//            // Clean price string: remove commas, $, spaces
//            let cleaned = listing.price
//                .replacingOccurrences(of: ",", with: "")
//                .replacingOccurrences(of: "$", with: "")
//                .trimmingCharacters(in: .whitespacesAndNewlines)
//
//            // Convert to Double
//            guard let price = Double(cleaned) else {
//                return false // skip invalid or non-numeric prices
//            }
//
//            //            return price >= priceRange.lowerBound &&
//            //                   price <= priceRange.upperBound
//            return price <= maxPrice
//
//        }
//
//        // BEDROOMS FILTER
//        if let beds = selectedBedrooms {
//            if beds == 3 {
//                filtered = filtered.filter { $0.numberOfBedrooms >= 3 }
//            } else {
//                filtered = filtered.filter { $0.numberOfBedrooms == beds }
//            }
//        }
//
//        // VERIFIED FILTER
//        if showVerifiedOnly {
//            filtered = filtered.filter { $0.isAvailable }   // ← update based on your actual field
//        }
//
//        return filtered
//    }
//
//    func resetFilters() {
//        //        priceRange = 600...5000
//        maxPrice <= maxPrice
//        selectedBedrooms = nil
//        showVerifiedOnly = false
//    }
//
//    // -------------------------------------------------------------
//    // MARK: CURRENCY SELECTOR
//    // -------------------------------------------------------------
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
//
//    // -------------------------------------------------------------
//    // MARK: ADD LISTING BUTTON
//    // -------------------------------------------------------------
//
//    struct AddListingButton: View {
//        var body: some View {
//            Button(action: {}) {
//                Image(systemName: "plus.square.on.square.fill")
//                    .font(.system(size: 26))
//            }
//        }
//    }
//
//
//    // -------------------------------------------------------------
//    // MARK: LISTING TILE
//    // -------------------------------------------------------------
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
//
//    // -------------------------------------------------------------
//    // MARK: CUSTOM TAB BAR
//    // -------------------------------------------------------------
//
//    struct CustomTabBar: View {
//        @Binding var selectedTab: String
//
//        private let tabs = [
//            ("Explore", "house.fill"),
//            ("Search", "magnifyingglass"),
//            ("Inbox", "message.fill"),
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
//
//}


// -------------------------------------------------------------
// MARK: EXPLORE VIEW (MAIN SCREEN)
// -------------------------------------------------------------
import SwiftUI

struct SecureRentalHomePage: View {

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

    @State private var selectedTab: String = "Explore"
    @State private var showAddListing = false


    var body: some View {
        ZStack(alignment: .bottom) {

            // MAIN CONTENT
            VStack(spacing: 0) {
                
                NavigationLink(
                    destination: CreateRentalListingView(viewModel: viewModel),
                    isActive: $showAddListing
                ) {
                    EmptyView()
                }
                
                // HEADER
                HStack {
                    Spacer()
//                    AddListingButton()
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

                // TAB BAR
                CustomTabBar(selectedTab: $selectedTab)
                    .zIndex(3)
            }
            .ignoresSafeArea(.keyboard)


            // -------------------------------------------------------------
            // FIX: FILTER OVERLAY MOVED OUT OF VSTACK TO PREVENT TAB BAR SHIFT
            // -------------------------------------------------------------
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
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(11)
            }
            // -------------------------------------------------------------
        }
    }

    // -------------------------------------------------------------
    // MARK: SEARCH BAR
    // -------------------------------------------------------------

//    struct SearchBar: View {
//        @State private var text = ""
//
//        var body: some View {
//            HStack {
//                Image(systemName: "magnifyingglass")
//                TextField("Search rentals...", text: $text)
//            }
//            .padding(10)
//            .background(Color(.systemGray6))
//            .cornerRadius(10)
//        }
//    }
    
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
        var filtered = listings

        let converted = listings.filter { listing in
            let cleaned = listing.price
                .replacingOccurrences(of: ",", with: "")
                .replacingOccurrences(of: "$", with: "")
                .trimmingCharacters(in: .whitespaces)
            return Double(cleaned) ?? 0 <= maxPrice
        }
        filtered = converted

        if let beds = selectedBedrooms {
            if beds == 3 {
                filtered = filtered.filter { $0.numberOfBedrooms >= 3 }
            } else {
                filtered = filtered.filter { $0.numberOfBedrooms == beds }
            }
        }

        if showVerifiedOnly {
            filtered = filtered.filter { $0.isAvailable }
        }

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

//    struct AddListingButton: View {
//        var body: some View {
//            Button(action: {}) {
//                Image(systemName: "plus.square.on.square.fill")
//                    .font(.system(size: 26))
//            }
//        }
//    }
    
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
            ("Explore", "house.fill"),
            ("Search", "magnifyingglass"),
            ("Inbox", "message.fill"),
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






