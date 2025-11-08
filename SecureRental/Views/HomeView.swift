//
//  HomeView.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2024-10-19.
//
//
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @Binding var rootView: RootView
    @EnvironmentObject var dbHelper: FireDBHelper
    
    @State private var selectedTab = 0
    @State private var showMessageView = false
    @State private var showCreateListingView = false
    @StateObject var viewModel = RentalListingsViewModel()
    
    @State private var showLocationConsentAlert = false
    @State private var shouldOpenLocationSheetAfterConsent = false   // 👈 NEW
    @State private var isConsentFlowLoading = false                  // 👈 NEW

    var body: some View {
        ZStack {
            // Main TabView Content
            TabView(selection: $selectedTab) {
                NavigationView {
                    ZStack {   // 👈 NEW: keep content fixed, overlay loader
                        VStack {
                            if let user = dbHelper.currentUser {
                                HStack {
                                    Text("Welcome, \(user.name)")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    
                                    Spacer() // pushes the button to the right
                                    
                                    // Right side: My Listings button
                                    NavigationLink(destination: MyListingsView().environmentObject(dbHelper)) {
                                        Label("My Listings", systemImage: "house.fill")
                                            .font(.subheadline)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.blue.opacity(0.1))
                                            .foregroundColor(.blue)
                                            .cornerRadius(8)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)
                                
                                NavigationLink(destination: RentalSearchView(viewModel: viewModel)) {
                                    HStack {
                                        Image(systemName: "magnifyingglass") // search icon
                                            .foregroundColor(.gray)
                                        
                                        Text("Search rental listing") // placeholder text
                                            .foregroundColor(.gray)
                                            .font(.body)
                                        
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color(.systemGray6)) // light background
                                    .cornerRadius(10)
                                }
                                .padding(.horizontal)
                                
                                // 👉 Listing count / empty state / list
                                // ❗️content always shown, no more if-loading-here
                                HStack {
                                    Image(systemName: "list.bullet.rectangle")
                                        .foregroundColor(.blue)
                                    Text("\(viewModel.locationListings.count) \(viewModel.locationListings.count == 1 ? "listing" : "listings") found")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    Text("based on your preferences.")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.top, 6)
                                
                                if viewModel.locationListings.isEmpty {
                                    // Empty state
                                    VStack(spacing: 8) {
                                        Image(systemName: "tray")
                                            .font(.system(size: 32))
                                            .foregroundColor(.gray.opacity(0.6))
                                        Text("No listings found in your area.")
                                            .font(.body)
                                            .foregroundColor(.secondary)
                                        Text("Try expanding your radius or updating your location.")
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                    .padding()
                                } else {
                                    // Actual list
                                    List($viewModel.locationListings) { $listing in
                                        NavigationLink(
                                            destination: RentalListingDetailView(listing: listing)
                                                .environmentObject(dbHelper)
                                        ) {
                                            HStack {
                                                if let firstURL = listing.imageURLs.first,
                                                   let url = URL(string: firstURL) {
                                                    AsyncImage(url: url) { phase in
                                                        switch phase {
                                                        case .empty:
                                                            ProgressView()
                                                        case .success(let image):
                                                            image.resizable()
                                                                .scaledToFit()
                                                                .frame(width: 100, height: 100)
                                                                .cornerRadius(8)
                                                        case .failure:
                                                            Image(systemName: "photo")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 100, height: 100)
                                                                .foregroundColor(.gray)
                                                        @unknown default:
                                                            EmptyView()
                                                        }
                                                    }
                                                }
                                                
                                                VStack(alignment: .leading) {
                                                    Text(listing.title)
                                                        .font(.headline)
                                                    Text("$\(listing.price)/month")
                                                        .font(.subheadline)
                                                }
                                                Spacer()
                                            } // HStack
                                        } // NavigationLink
                                    } // List
                                }
                            }
                        }
                        
                        // 👇 overlay loader so UI doesn’t jump
                        if viewModel.isLoading || isConsentFlowLoading {
                            Color.black.opacity(0.05)
                                .ignoresSafeArea()
                            ProgressView("Loading Listings...")
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(12)
                        }
                    }
                    .navigationTitle("Secure Rental")
                    .onAppear {
                        Task {
                            // 1️⃣ Fetch user from Firestore
                            if let uid = Auth.auth().currentUser?.uid,
                               let fetchedUser = await dbHelper.getUser(byUID: uid) {
                                dbHelper.currentUser = fetchedUser
                                
                                if let lat = fetchedUser.latitude,
                                   let lon = fetchedUser.longitude {
                                    await viewModel.updateCityFromStoredCoordinates(latitude: lat, longitude: lon)
                                }
                            }
                            
                            // 2️⃣ Let ViewModel handle location consent and fetching listings
                            await viewModel.loadHomePageListings()
                        }
                    } // onAppear
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                showCreateListingView = true
                            }) {
                                Image(systemName: "plus")
                            }
                            .help("Create a new listing")
                            .accessibilityLabel("Create a new listing")
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                // ✅ only allow if user has given location consent
                                if let user = dbHelper.currentUser, user.locationConsent == true {
                                    viewModel.showUpdateLocationSheet = true
                                } else {
                                    // remember that user wanted to open the sheet
                                    shouldOpenLocationSheetAfterConsent = true
                                    isConsentFlowLoading = true  // new
                                    viewModel.showLocationConsentAlert = true
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "mappin.and.ellipse")
                                    if let city = viewModel.currentCity {
                                        Text(city)
                                            .font(.subheadline)
                                    } else {
                                        Text("Set Location")
                                            .font(.subheadline)
                                    }
                                }
                                .padding(8)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                    
                }
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
                
                // Messages Tab
                MyChatsView()
                    .tabItem {
                        Label("Messages", systemImage: "message")
                    }
                    .tag(1)
                
                // Favourites Tab
                FavouriteListingsView(viewModel: viewModel)
                    .tabItem {
                        Label("Favourites", systemImage: "star.fill")
                    }
                    .tag(2)
                
                // Profile Tab
                ProfileView(rootView: $rootView)
                    .tabItem {
                        Label("Profile", systemImage: "person.circle")
                    }
                    .tag(3)
            }
            
            // Chatbot icon button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showMessageView = true
                        print("Chatbot tapped")
                    }) {
                        Image(systemName: "bubble.right.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                    }
                    .padding(.bottom, 50)
                    .padding(.trailing, 20)
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
                    
                    // in any case, stop the loading flag
                    isConsentFlowLoading = false
                    shouldOpenLocationSheetAfterConsent = false
                }
            }
        }
    }
}
