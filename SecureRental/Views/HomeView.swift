//
//  HomeView.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2024-10-19.
//  Refined UI: hunter green theme + single-row compact cards
//

import SwiftUI
import FirebaseAuth

// MARK: - Brand Colors

extension Color {
    /// Hunter green-ish tone for SecureRental branding
    static let hunterGreen = Color(red: 0.21, green: 0.67, blue: 0.23)
}

// MARK: - Skeleton Listing Card (1 per row)

struct SkeletonListingCardView: View {
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.hunterGreen.opacity(0.12))
                .frame(width: 110, height: 90)

            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 14)

                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 10)

                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.18))
                    .frame(width: 110, height: 8)
            }

            Spacer()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
        )
        .shimmer()
    }
}

// MARK: - Listing Card (1 per row, fixed image size)

struct ListingCardView: View {
    let listing: Listing

    var body: some View {
        HStack(spacing: 12) {
            // Fixed-size thumbnail
            ZStack {
                if let firstURL = listing.imageURLs.first,
                   let url = URL(string: firstURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            Image(systemName: "house.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.gray.opacity(0.7))
                                .padding(12)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "house.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray.opacity(0.7))
                        .padding(12)
                }
            }
            .frame(width: 110, height: 90)          // 👈 consistent size
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Text block
            VStack(alignment: .leading, spacing: 4) {
                Text(listing.title)
                    .font(.footnote.weight(.semibold)) // smaller
                    .lineLimit(2)

                Text("$\(listing.price)/month")
                    .font(.caption.weight(.semibold))  // smaller + bold
                    .foregroundColor(.hunterGreen)

                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(listing.city), \(listing.province)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        )
    }
}

// MARK: - Home View

struct HomeView: View {
    @Binding var rootView: RootView
    @EnvironmentObject var dbHelper: FireDBHelper
    
    @State private var selectedTab = 0
    @State private var showMessageView = false
    @State private var showCreateListingView = false
    @StateObject var viewModel = RentalListingsViewModel()
    
    @State private var showLocationConsentAlert = false
    @State private var shouldOpenLocationSheetAfterConsent = false
    @State private var isConsentFlowLoading = false

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {

                // MARK: - Home Tab
                NavigationView {
                    ZStack {
                        LinearGradient(
                            colors: [
                                Color.hunterGreen.opacity(0.06),
                                Color(.systemBackground)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea()
                        
                        VStack(spacing: 12) {
                            if let user = dbHelper.currentUser {
                                // HEADER
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("SecureRental")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.hunterGreen)
                                        Text("Hi, \(user.name)")
                                            .font(.headline)
                                        Text("Verified landlords. Safer rentals.")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    NavigationLink(
                                        destination: MyListingsView().environmentObject(dbHelper)
                                    ) {
                                        Label("My Listings", systemImage: "house.fill")
                                            .font(.caption)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Color.hunterGreen.opacity(0.10))
                                            .foregroundColor(.hunterGreen)
                                            .clipShape(Capsule())
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 8)
                                
                                // SEARCH BAR
                                NavigationLink(
                                    destination: RentalSearchView(viewModel: viewModel)
                                ) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(.hunterGreen)
                                        Text("Search rental listing")
                                            .foregroundColor(.gray)
                                            .font(.subheadline)
                                        Spacer()
                                    }
                                    .padding(10)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
                                }
                                .padding(.horizontal, 16)

                                // LISTING COUNT
                                HStack(spacing: 6) {
                                    Image(systemName: "lock.shield")
                                        .foregroundColor(.hunterGreen)
                                        .font(.caption)

                                    Text("\(viewModel.locationListings.count)")
                                        .font(.caption.weight(.bold))
                                        .foregroundColor(.black)
                                    Text(viewModel.locationListings.count == 1 ?
                                         "listing" :
                                         "listings")
                                        .font(.caption.weight(.bold))
                                        .foregroundColor(.black)

                                    Text("based on your preferences")
                                        .font(.caption)
                                        .foregroundColor(.black)

                                    Spacer()
                                }
                                .padding(.horizontal, 16)

                                // MARK: - LISTINGS CONTENT (1 per row)
                                Group {
                                    if viewModel.isLoading {
                                        ScrollView {
                                            LazyVStack(spacing: 10) {
                                                ForEach(0..<6, id: \.self) { _ in
                                                    SkeletonListingCardView()
                                                }
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.top, 4)
                                            .padding(.bottom, 10)
                                        }
                                    } else if viewModel.locationListings.isEmpty {
                                        VStack(spacing: 8) {
                                            Image(systemName: "tray")
                                                .font(.system(size: 30))
                                                .foregroundColor(.gray.opacity(0.6))
                                            Text("No listings found in your area.")
                                                .font(.body)
                                                .foregroundColor(.secondary)
                                            Text("Try expanding your radius or updating your location.")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                        .padding()
                                    } else {
                                        ScrollView {
                                            LazyVStack(spacing: 10) {   // 👈 one card per row
                                                ForEach(viewModel.locationListings) { listing in
                                                    NavigationLink(
                                                        destination: RentalListingDetailView(listing: listing)
                                                            .environmentObject(dbHelper)
                                                    ) {
                                                        ListingCardView(listing: listing)
                                                    }
                                                    .buttonStyle(.plain)
                                                }
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.top, 4)
                                            .padding(.bottom, 10)
                                        }
                                    }
                                }
                                .animation(.easeInOut(duration: 0.2), value: viewModel.isLoading)
                            }
                        }

                        if isConsentFlowLoading {
                            Color.black.opacity(0.05)
                                .ignoresSafeArea()
                            ProgressView("Updating location…")
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(12)
                        }
                    }
                    .navigationTitle("Home")
                    .navigationBarTitleDisplayMode(.inline)
                    .onAppear {
                        Task {
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
                            
                            await viewModel.loadHomePageListings()
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                showCreateListingView = true
                            }) {
                                Image(systemName: "plus")
                            }
                            .accessibilityLabel("Create a new listing")
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                if let user = dbHelper.currentUser, user.locationConsent == true {
                                    viewModel.showUpdateLocationSheet = true
                                } else {
                                    shouldOpenLocationSheetAfterConsent = true
                                    isConsentFlowLoading = true
                                    viewModel.showLocationConsentAlert = true
                                }
                            }) {
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
                                .background(Color.hunterGreen.opacity(0.12))
                                .foregroundColor(.hunterGreen)
                                .clipShape(Capsule())
                            }
                        }
                    }
                }
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
                
                // MARK: - Messages Tab
                MyChatsView()
                    .tabItem {
                        Label("Messages", systemImage: "message")
                    }
                    .tag(1)
                
                // MARK: - Favourites Tab
                FavouriteListingsView(viewModel: viewModel)
                    .tabItem {
                        Label("Favourites", systemImage: "star.fill")
                    }
                    .tag(2)
                
                // MARK: - Profile Tab
                ProfileView(rootView: $rootView)
                    .tabItem {
                        Label("Profile", systemImage: "person.circle")
                    }
                    .tag(3)
            }
            
            // MARK: - Floating Chatbot Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showMessageView = true
                    }) {
                        Image(systemName: "bubble.right.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.hunterGreen)
                            .clipShape(Circle())
                            .shadow(radius: 8)
                    }
                    .padding(.bottom, 44)
                    .padding(.trailing, 18)
                }
            }
        }
        .sheet(isPresented: $showMessageView) {
            ChatbotView()
        }
        .sheet(isPresented: $showCreateListingView) {
            CreateRentalListingView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showUpdateLocationSheet) {
            UpdateLocationView(viewModel: viewModel)
        }
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
