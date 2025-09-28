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
    
    var body: some View {
        ZStack {
                // Main TabView Content
            TabView(selection: $selectedTab) {
                NavigationView {
                    VStack {
                        if let user = dbHelper.currentUser {
                                                    Text("Welcome, \(user.name)")
                                                        .font(.headline)
                                                        .padding()
                                                }
                        NavigationLink("Search Rental Listings", destination: RentalSearchView(viewModel: viewModel))
                            .padding()
                        
                        List($viewModel.listings) { $listing in
                            NavigationLink(destination: RentalListingDetailView(listing: listing)) {
                                HStack {
                                    if let firstImage = listing.imageURLs.first {
                                        Image(firstImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(8)
                                    }
                                    VStack(alignment: .leading) {
                                        Text(listing.title)
                                            .font(.headline)
                                        Text("$\(listing.price)/month")
                                            .font(.subheadline)
                                    }
                                    Spacer()
                                    
                                        // Favorite Button
                                    Button(action: {
                                        viewModel.toggleFavorite(for: listing)
                                    }) {
                                        Image(systemName: viewModel.isFavorite(listing) ? "heart.fill" : "heart")
                                            .foregroundColor(viewModel.isFavorite(listing) ? .red : .gray)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    
                                        // Comment (Rate) Button
                                    Button(action: {
                                        selectedListingForComment = listing
                                        showCommentView = true
                                    }) {
                                        Image(systemName: "star.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    
                                }
                            }
                        }
                        .navigationTitle("Secure Rental")
                        .onAppear {
                            viewModel.fetchListings()
                        }
//                        .onAppear { $viewModel.startListeningAllListings }
//                        .onDisappear { viewModel.stopListening() }
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    showCreateListingView = true
                                }) {
                                    Image(systemName: "plus")
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
        }
        .fullScreenCover(isPresented: $showMessageView) {
//            NavigationLink("My Chats", destination: MyChatsView())
//                   .padding()
            MyChatsView()
        }
        .sheet(isPresented: $showCreateListingView) {
            CreateRentalListingView(viewModel: viewModel)
        }
//        .sheet(item: $selectedListing) { listing in
//            EditRentalListingView(viewModel: viewModel, listing: listing)
//        }
        .sheet(item: $selectedListingForComment) { listing in
            CommentView(listing: listing, viewModel: viewModel)
        }
    }
}

