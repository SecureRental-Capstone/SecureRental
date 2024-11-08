//
//  HomeView.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2024-10-19.
//
//
// HomeView.swift
import SwiftUI

struct HomeView: View {
    @Binding var rootView: RootView
    @State private var selectedTab = 0
    @State private var showMessageView = false
    @State private var showProfileView = false
    @State private var showCreateListingView = false
    @State private var showEditListingView = false
    @State private var selectedListing: RentalListing?
    @StateObject var user = User.sampleUser

    @StateObject var viewModel = RentalListingsViewModel()
    
    var body: some View {
        ZStack {
            // Main TabView Content
            TabView(selection: $selectedTab) {
                NavigationView {
                    VStack {
                        SearchBar(text: $viewModel.searchText)
                            .padding(.horizontal)
                        
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
                        .navigationTitle("Rental Listings")
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
                
//                // Message View for the Messages tab
//                MessageView()
//                    .tabItem {
//                        Label("Messages", systemImage: "message")
//                    }
//                    .tag(1)
//                
//                ProfileView(user: viewModel.user)  // Show ProfileView when this tab is selected
//                    .tabItem {
//                        Label("Profile", systemImage: "person.circle")
//                    }
//                    .tag(2)
                 // Message View for the Messages tab
                                MessageView()
                                    .tabItem {
                                        Label("Messages", systemImage: "message")
                                    }   .tag(1)
                
                                ProfileView(user: user)  // Show ProfileView when this tab is selected
                                    .tabItem {
                                        Label("Profile", systemImage: "person.circle")
                                    }
                                    .tag(2)
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
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(rootView: .constant(.main))
    }
}

//import SwiftUI
//
//struct HomeView: View {
//    
//    @Binding var rootView: RootView
//    @State private var selectedTab = 0
//    @State private var showMessageView = false // State to show MessageView
//    @State private var showProfileView = false
//
//    @StateObject var user = User.sampleUser
//    let listings = [ RentalListing(
//        title: "Cozy Apartment",
//        description: "A charming one-bedroom apartment in the heart of downtown.",
//        price: "$1200/month",
//        imageName: "apartment1",
//        location: "Toronto, ON",
//        isAvailable: true,
//        datePosted: Date(),
//        numberOfBedrooms: 1,
//        numberOfBathrooms: 1,
//        squareFootage: 600,
//        amenities: ["WiFi", "Washer/Dryer", "Pet-friendly"]
//    ),
//     RentalListing(
//        title: "Luxury Condo",
//        description: "Spacious 2-bedroom, 2-bathroom condo with amazing city views.",
//        price: "$2500/month",
//        imageName: "condo1",
//        location: "Toronto, ON",
//        isAvailable: false,
//        datePosted: Date().addingTimeInterval(-3600), // Posted 1 hour ago
//        numberOfBedrooms: 2,
//        numberOfBathrooms: 2,
//        squareFootage: 1100,
//        amenities: ["Gym", "Parking", "Swimming Pool"]
//     )]
//    
//    var body: some View {
//        ZStack {
//            //main TabView Content
//            TabView(selection: $selectedTab) {
//                NavigationView {
//                    //Rental Listings
//                    List(listings) { listing in
//                           HStack {
//                               
//                               Image(listing.imageName)
//                                   .resizable()
//                                   .scaledToFit()
//                                   .frame(width: 100, height: 100)
//                                   .cornerRadius(8)
//                               
//                               VStack(alignment: .leading) {
//                                   Text(listing.title)
//                                       .font(.headline)
//                                   Text(listing.price)
//                                       .font(.subheadline)
//                               }
//                           }
//                       }
//                       .navigationTitle("Rental Listings")
//                }
//                .tabItem {
//                    Label("Home", systemImage: "house")
//                }
//                .tag(0)
//                
//                    // Message View for the Messages tab
//                MessageView()
//                    .tabItem {
//                        Label("Messages", systemImage: "message")
//                    }   .tag(1)
//                
//                ProfileView(user: user)  // Show ProfileView when this tab is selected
//                    .tabItem {
//                        Label("Profile", systemImage: "person.circle")
//                    }
//                    .tag(2)
//            }
//            
//            //chatbot icon
//            VStack {
//                Spacer()
//                HStack {
//                    Spacer()
//                    Button(action: {
//                        showMessageView = true
//                        
//                        print("Chatbot tapped")
//                    }) {
//                        Image(systemName: "bubble.right.fill")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 30, height: 30)
//                            .foregroundColor(.white)
//                            .padding()
//                            .background(Color.blue)
//                            .clipShape(Circle())
//                            .shadow(radius: 10)
//                    }
//                    .padding(.bottom, 50)
//                    .padding(.trailing, 20)
//                }
//            }
//        } 
//        .fullScreenCover(isPresented: $showMessageView) {
//            MessageView() 
//        }
//    }
//}
//
//
//    
