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
    let listings = [
            RentalListing(title: "Cozy Apartment", price: "$1200/month", imageName: "examplepic1"),
            RentalListing(title: "Luxury Condo", price: "$2500/month", imageName: "examplepic2"),
            RentalListing(title: "Charming Cottage", price: "$1500/month", imageName: "examplepic3")
        ]

    
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
                
                Text("Favorites")
                    .tabItem {
                        Label("Messages", systemImage: "star")
                    }
                    .tag(1)
                
                Text("Profile")
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
                    .tag(2)
            }
            
            //chatbot icon
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        //action to show the chatbot
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

    }
}

struct RentalListing: Identifiable {
    
    let id = UUID()
    let title: String
    let price: String
    let imageName: String
}


    
