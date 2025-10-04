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
    @State private var showEditListingView = false
    @State private var showCommentView = false
    @State private var selectedListing: Listing?
    @State private var selectedListingForComment: Listing?
    @StateObject var user = AppUser.sampleUser
    @StateObject var viewModel = RentalListingsViewModel()
    @StateObject var locationManager = LocationManager()
    @StateObject var locationFilter = LocationFilter()
    
    var body: some View {
        ZStack {
                // Main TabView Content
            TabView(selection: $selectedTab) {
                NavigationView {
                    VStack {
                        if let user = dbHelper.currentUser {
                            HStack {
                                Text("Welcome, \(user.name)")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Spacer() // pushes the button to the right
                                
                                    // Right side: My Listings button
                                NavigationLink(destination: MyListingsView()) {
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
                            
                            List($viewModel.listings) { $listing in
                                NavigationLink(destination: RentalListingDetailView(listing: listing)) {
                                    HStack {
                                        if let firstURL = listing.imageURLs.first, let url = URL(string: firstURL) {
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
                                    }
                                }
                            }
                            .navigationTitle("Secure Rental")
                            .onAppear {
//                                if let userLocation = LocationManager.shared.currentLocation {
//                                            await viewModel.fetchListings(around: userLocation, radiusInKm: 5.0)
//                                        }
                                if let location = locationManager.currentLocation {
                                    viewModel.fetchListings(around: location, radiusInKm: locationFilter.radiusInKm)
                                }
                                else {
                                // fallback if location not available
                                    let defaultLocation = CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832)
                                    await viewModel.fetchListings(around: defaultLocation)
                                }
                                
                            }
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button(action: {
                                        showCreateListingView = true
                                    }) {
                                        Image(systemName: "plus")
                                    }
                                    .help("Create a new listing")            // ✅ macOS hover tooltip
                                    .accessibilityLabel("Create a new listing") // ✅ iOS VoiceOver label
                                }
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
            
            VStack {
                Slider(value: $locationFilter.radiusInKm, in: 1...50, step: 1) {
                    Text("Radius")
                }
                Text("Showing listings within \(Int(locationFilter.radiusInKm)) km")
                Button("Update Listings") {
                    if let loc = locationManager.currentLocation {
                        viewModel.fetchListings(around: loc, radiusInKm: locationFilter.radiusInKm)
                    }
                }
            }
            }
            .sheet(isPresented: $showMessageView) {
                ChatbotView()
            }
            .sheet(isPresented: $showCreateListingView) {
                CreateRentalListingView(viewModel: viewModel)
            }
            .alert(isPresented: $locationManager.showPermissionAlert) {
                Alert(
                    title: Text("Location Permission Needed"),
                    message: Text("We need your location to show listings nearby. Please enable location access in settings."),
                    dismissButton: .default(Text("OK"))
                )
            }

        }
    }

