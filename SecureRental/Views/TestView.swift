//
//  TestView.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2025-11-18.
//

import SwiftUI

struct SecureRentalHomePage: View {

    let fireDBHelper: FireDBHelper = FireDBHelper.getInstance()

    @Binding var rootView: RootView
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
    @State private var float = false
    @State private var showHint = true

    // 🔹 Location consent / flow state
    @State private var isConsentFlowLoading = false
    @State private var shouldOpenLocationSheetAfterConsent = false
    @State private var reopenFilterAfterLocation = false

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
                        FavouriteListingsView(viewModel: viewModel)
                            .environmentObject(fireDBHelper)
                            .environmentObject(viewModel)
                    case "Profile":
                        ProfileView(rootView: $rootView)
                    default:
                        exploreContent
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // TAB BAR
                CustomTabBar(selectedTab: $selectedTab)
                    .zIndex(3)
            }
            .ignoresSafeArea(.keyboard)

            // FILTER OVERLAY + CARD
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
                        // 🔹 Use unified location handler (from Filter)
                        handleLocationButtonTapped(fromFilter: true)
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(11)
                .environmentObject(currencyManager)
                .environmentObject(viewModel)
            }

            // 🔹 Light overlay while handling consent / updating
            if isConsentFlowLoading {
                ZStack {
                    Color.black.opacity(0.05)
                        .ignoresSafeArea()
                    ProgressView("Updating location…")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                }
                .transition(.opacity)
                .zIndex(20)
            }
        }
        // 🔹 Location sheet is driven by the view model flag
        .sheet(isPresented: $viewModel.showUpdateLocationSheet) {
            NavigationStack {
                UpdateLocationView(
                    viewModel: viewModel,
                    onBack: {
                        // Only reopen filter if user came from FilterCard
                        if reopenFilterAfterLocation {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                withAnimation {
                                    showFilterCard = true
                                }
                            }
                        }
                    }
                )
                .environmentObject(fireDBHelper)
            }
        }
        // 🔹 Location consent alert
        .alert(
            "Allow SecureRental to access your location?",
            isPresented: $viewModel.showLocationConsentAlert
        ) {
            Button("No") {
                Task {
                    await viewModel.handleLocationConsentResponse(granted: false)
                    isConsentFlowLoading = false
                    shouldOpenLocationSheetAfterConsent = false
                    reopenFilterAfterLocation = false
                }
            }
            Button("Yes") {
                Task {
                    await viewModel.handleLocationConsentResponse(granted: true)

                    if shouldOpenLocationSheetAfterConsent {
                        viewModel.showUpdateLocationSheet = true
                    }

                    isConsentFlowLoading = false
                    shouldOpenLocationSheetAfterConsent = false
                    // keep reopenFilterAfterLocation (we still want to reopen filter after sheet)
                }
            }
        } message: {
            Text("SecureRental uses your location to show nearby rentals and improve your search experience.")
        }
    }

    // -------------------------------------------------------------
    // MARK: Explore (original listing feed)
    // -------------------------------------------------------------
    private var exploreContent: some View {
        VStack(spacing: 0) {

            // HEADER ROW
            HStack {
                Text("SecureRental")
                    .font(.title3).bold()

                Spacer()

                // 🔹 Location chip
                Button {
                    handleLocationButtonTapped(fromFilter: false)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                        if let city = viewModel.currentCity {
                            Text(city)
                                .font(.caption)
                        } else {
                            Text("Set Location")
                                .font(.caption)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.10))   // or Color.hunterGreen.opacity(0.12) if defined
                    .foregroundColor(.blue)
                    .clipShape(Capsule())
                }

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
                            .shadow(color: Color.blue.opacity(0.15), radius: 12, y: 6)
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

                // Hide hint after 5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    withAnimation { showHint = false }
                }
            }

        }
    }

    // -------------------------------------------------------------
    // MARK: Location button handler (header + filter)
    // -------------------------------------------------------------
    private func handleLocationButtonTapped(fromFilter: Bool) {
        // If tap came from the filter card, close it and remember to reopen
        if fromFilter {
            reopenFilterAfterLocation = true
            withAnimation {
                showFilterCard = false
            }
        } else {
            reopenFilterAfterLocation = false
        }

        // If user already gave consent, just open the sheet
        if let user = dbHelper.currentUser, user.locationConsent == true {
            viewModel.showUpdateLocationSheet = true
        } else {
            // Otherwise, show consent flow
            shouldOpenLocationSheetAfterConsent = true
            isConsentFlowLoading = true
            viewModel.showLocationConsentAlert = true
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

        // PRICE FILTER (with currency conversion)
        filtered = filtered.filter { listing in
            let cleaned = listing.price
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted)
                .joined()

            let cadValue = Double(cleaned) ?? 0

            let listingInSelectedCurrency = currencyManager.convertToSelectedCurrency(cadValue)
            let maxPriceInSelectedCurrency = currencyManager.convertToSelectedCurrency(maxPrice)

            return listingInSelectedCurrency <= maxPriceInSelectedCurrency
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

                print("🛏 BED FILTER -> id: \(listing.id) actualBeds: \(listing.numberOfBedrooms) selected: \(beds) pass: \(pass)")
                return pass
            }
        }

        // VERIFIED PROPERTIES FILTER
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
