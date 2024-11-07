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
    @State private var showMessageView = false // State to show MessageView
    @State private var showProfileView = false
//    let listings = [
//            RentalListing(title: "Cozy Apartment", price: "$1200/month", imageName: "examplepic1"),
//            RentalListing(title: "Luxury Condo", price: "$2500/month", imageName: "examplepic2"),
//            RentalListing(title: "Charming Cottage", price: "$1500/month", imageName: "examplepic3")
//        ]
    @StateObject var user = User.sampleUser
    let listings = [ RentalListing(
        title: "Cozy Apartment",
        description: "A charming one-bedroom apartment in the heart of downtown.",
        price: "$1200/month",
        imageName: "apartment1",
        location: "Toronto, ON",
        isAvailable: true,
        datePosted: Date(),
        numberOfBedrooms: 1,
        numberOfBathrooms: 1,
        squareFootage: 600,
        amenities: ["WiFi", "Washer/Dryer", "Pet-friendly"]
    ),
                     RentalListing(
                        title: "Luxury Condo",
                        description: "Spacious 2-bedroom, 2-bathroom condo with amazing city views.",
                        price: "$2500/month",
                        imageName: "condo1",
                        location: "Toronto, ON",
                        isAvailable: false,
                        datePosted: Date().addingTimeInterval(-3600), // Posted 1 hour ago
                        numberOfBedrooms: 2,
                        numberOfBathrooms: 2,
                        squareFootage: 1100,
                        amenities: ["Gym", "Parking", "Swimming Pool"]
                     )]
    
    var body: some View {
        ZStack {
            //main TabView Content
            TabView(selection: $selectedTab) {
                NavigationView {
                    //Rental Listings
                    List(listings) { listing in
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
                           }
                       }
                       .navigationTitle("Rental Listings")
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
                
                ProfileView(user: user)  // Show ProfileView when this tab is selected
                    .tabItem {
                        Label("Profile", systemImage: "person.circle")
                    }
                    .tag(2)
            }
            
            //chatbot icon
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
    }
}

//struct RentalListing: Identifiable {
//    
//    let id = UUID()
//    let title: String
//    let price: String
//    let imageName: String
//}


    
