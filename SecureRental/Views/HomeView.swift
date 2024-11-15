//
//  HomeView.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2024-10-19.
//

import SwiftUI

struct HomeView: View {
    @Binding var rootView: RootView
    @State private var selectedTab = 0
    @State private var showMessageView = false
    @State private var showProfileView = false
    @State private var showCreateListingView = false
    @State private var showEditListingView = false
//    @State private var selectedListing: RentalListing?
    @State private var showCommentView = false // For comment/ratings view
    @State private var selectedListing: RentalListing?
    @State private var selectedListingForComment: RentalListing?
    @StateObject var user = User.sampleUser

    @StateObject var viewModel = RentalListingsViewModel()
    
    var body: some View {
        ZStack {
            // Main TabView Content
            TabView(selection: $selectedTab) {
                NavigationView {
                    VStack {

                        NavigationLink("Search Rental Listings", destination: RentalSearchView(viewModel: viewModel))
                                            .padding()
//                        List(viewModel.listings) { listing in
//                                            NavigationLink(destination: EditRentalListingView(viewModel: viewModel, listing: listing)) {
//                                                Text(listing.title)
//                                            }
//                                        }
                        

                        List(viewModel.listings) { listing in
                            NavigationLink(destination: RentalListingDetailView(listing: listing)) {
                                HStack {
                                    Image(listing.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(8)
                                    
                                    VStack(alignment: .leading) {
                                        Text(listing.title)
                                            .font(.headline)
                                        Text(listing.price)
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
                                    
                                    Button(action: {
                                        selectedListing = listing
                                        showEditListingView = true
                                    }) {
                                        Image(systemName: "pencil")
                                            .foregroundColor(.blue)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                        }
                        .navigationTitle("Secure Rental")
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
                
                // Message View for the Messages tab
                MessageView()
                    .tabItem {
                        Label("Messages", systemImage: "message")
                    }   .tag(1)
                
                FavouriteListingsView()  // Show ProfileView when this tab is selected
                    .tabItem {
                        Label("Favourites", systemImage: "star.fill")
                    }
                    .tag(2)
                
                ProfileView(user: user)  // Show ProfileView when this tab is selected
                    .tabItem {
                        Label("Profile", systemImage: "person.circle")
                    }
                    .tag(3)
            }
            
            // Chatbot icon
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
            MessageView()
        }
        .sheet(isPresented: $showCreateListingView) {
            CreateRentalListingView(viewModel: viewModel)
        }
        .sheet(item: $selectedListing) { listing in
            EditRentalListingView(viewModel: viewModel, listing: listing)
        }
        .sheet(item: $selectedListingForComment) { listing in
            CommentView(listing: listing, viewModel: viewModel)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(rootView: .constant(.main))
    }
}
