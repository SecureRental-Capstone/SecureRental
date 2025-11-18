////////
////////  TestView.swift
////////  SecureRental
////////
////////  Created by Haniya Akhtar on 2025-11-18.
////////
//////
//
import SwiftUI
import FirebaseAuth

struct SecureRentalHomePage: View {
    
    @EnvironmentObject var dbHelper: FireDBHelper
    
    @State private var showMessageView = false
    @State private var showCreateListingView = false
    
    @StateObject var viewModel = RentalListingsViewModel()
    @StateObject var currencyManager = CurrencyViewModel()
    
    @State private var searchText: String = ""
    
    // ⭐️ String-based tab selection (keep the old logic)
    @State private var selectedTab: String = "Search"
    
    // Location workflow
    @State private var shouldOpenLocationSheetAfterConsent = false
    @State private var isConsentFlowLoading = false
    
    var body: some View {
        ZStack(alignment: .bottom) {

            // -------------------------------------------------------------------
            // MARK: - STRING-BASED TAB SWITCH (old logic preserved)
            // -------------------------------------------------------------------
            switch selectedTab {

            // =====================================================
            // MARK: ================= HOME / SEARCH ================
            // =====================================================
            case "Search":
                NavigationView {
                    ZStack {
                        
                        // Background gradient
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.06),
                                Color(.systemBackground)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea()
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {

                                // -----------------------------------------------------
                                // MARK: - HEADER
                                // -----------------------------------------------------
                                HStack {
                                    Text("SecureRental")
                                        .font(.title3.weight(.bold))
                                        .foregroundColor(.blue)
                                    
                                    Spacer()
                                    
                                    if !currencyManager.currencies.isEmpty {
                                        CurrencyPickerButton(
                                            selected: $currencyManager.selectedCurrency,
                                            options: currencyManager.currencies
                                        )
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top, 10)
                                
                                // -----------------------------------------------------
                                // MARK: - SEARCH BAR
                                // -----------------------------------------------------
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
                                    
                                    Button {
                                        // Filter logic placeholder
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

                                // -----------------------------------------------------
                                // MARK: - VERIFIED BANNER
                                // -----------------------------------------------------
                                HStack(alignment: .top) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.white)
                                        .font(.title2)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Verified Student Housing")
                                            .font(.callout.weight(.bold))
                                            .foregroundColor(.white)

                                        Text("\(viewModel.locationListings.count) verified listings near you")
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

                                
                                // -----------------------------------------------------
                                // MARK: - LISTINGS SECTION
                                // -----------------------------------------------------

                                if viewModel.isLoading {
                                    LazyVStack(spacing: 20) {
                                        ForEach(0..<6, id: \.self) { _ in
                                            SkeletonListingCardView()
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 10)
                              //       MARK: Listing Cards

                                } else if viewModel.locationListings.isEmpty {

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

                                } else {

                                    Text("\(viewModel.locationListings.count) properties found")
                                        .font(.callout)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal)
                                        .padding(.top, 20)
                                    
//                                    LazyVStack(spacing: 20) {
//                                        ForEach(viewModel.locationListings) { listing in
//                                            NavigationLink {
//                                                RentalListingDetailView(listing: listing)
//                                                    .environmentObject(dbHelper)
//                                            } label: {
//                                                ListingCardView(listing: listing)
//                                            }
//                                            .buttonStyle(.plain)
//                                        }
//                                    }
//                                    .padding(.horizontal)
//                                    .padding(.vertical, 10)
                                    LazyVStack(spacing: 20) {
                                        ForEach(viewModel.locationListings) { listing in
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
                        }

                        // -----------------------------------------------------
                        // MARK: - LOCATION CONSENT LOADING OVERLAY
                        // -----------------------------------------------------
                        if isConsentFlowLoading {
                            Color.black.opacity(0.05).ignoresSafeArea()
                            
                            ProgressView("Updating location…")
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(12)
                        }
                    }
                    .navigationBarHidden(true)
                    .onAppear {
                        Task {
                            // -----------------------------------------------------
                            // MARK: FETCH USER
                            // -----------------------------------------------------
                            if let uid = Auth.auth().currentUser?.uid,
                               let fetchedUser = await dbHelper.getUser(byUID: uid) {
                                
                                dbHelper.currentUser = fetchedUser
                                
                                if let lat = fetchedUser.latitude,
                                   let lon = fetchedUser.longitude {
                                    await viewModel.updateCityFromStoredCoordinates(
                                        latitude: lat,
                                        longitude: lon
                                    )
                                }
                            }
                            
                            // -----------------------------------------------------
                            // MARK: LOAD LISTINGS
                            // -----------------------------------------------------
                            await viewModel.loadHomePageListings()
                        }
                    }
                }

            // =====================================================
            // MARK: ================= MESSAGES =====================
            // =====================================================
            case "Messages":
                NavigationView {
                    MyChatsView()
                }

            // =====================================================
            // MARK: ================= FAVOURITES ==================
            // =====================================================
            case "Favourites":
                NavigationView {
                    FavouriteListingsView(viewModel: viewModel)
                }

            // =====================================================
            // MARK: ================= PROFILE ======================
            // =====================================================
            case "Profile":
                NavigationView {
                   Text("Hello")// ProfileView()
                }

            default:
                EmptyView()
            }

            // -------------------------------------------------------------------
            // MARK: - Custom Bottom Tab Bar (STRING-BASED SELECTION)
            // -------------------------------------------------------------------
            CustomTabBar(selectedTab: $selectedTab)
        }

        // -------------------------------------------------------------------
        // MARK: - Chatbot / Create Listing / Update Location Sheets
        // -------------------------------------------------------------------
        .sheet(isPresented: $showMessageView) {
            ChatbotView()
        }
        .sheet(isPresented: $showCreateListingView) {
            CreateRentalListingView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showUpdateLocationSheet) {
            UpdateLocationView(viewModel: viewModel)
        }

        // -------------------------------------------------------------------
        // MARK: - Location Consent Alert
        // -------------------------------------------------------------------
        .alert("Allow SecureRental to access your location?", isPresented: $viewModel.showLocationConsentAlert) {
            Button("No") {
                Task {
                    await viewModel.handleLocationConsentResponse(granted: false)
                    isConsentFlowLoading = false
                    shouldOpenLocationSheetAfterConsent = false
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
                }
            }
        }
    }
}
