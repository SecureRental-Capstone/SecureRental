////
////  FavouriteListingsView.swift
////  SecureRental
////
////  Created by Anchal  Sharma  on 2024-11-14.
////

import SwiftUI

struct FavouriteListingsView: View {
    @ObservedObject var viewModel: RentalListingsViewModel
    @EnvironmentObject var dbHelper: FireDBHelper
    @StateObject var currencyManager = CurrencyViewModel()

    var body: some View {
        ZStack {
            
            // Background consistent with homepage
            LinearGradient(
                colors: [
                    Color.hunterGreen.opacity(0.06),
                    Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // EMPTY STATE
            if viewModel.favouriteListings.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 32))
                        .foregroundColor(.gray.opacity(0.7))

                    Text("No favourites yet")
                        .font(.headline)

                    Text("Tap the heart icon on a listing to save it here.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

            } else {
                // LISTINGS
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 20) {
                        ForEach(viewModel.favouriteListings) { listing in
                            
                            NavigationLink {
                                RentalListingDetailView(listing: listing)
                                    .environmentObject(dbHelper)
                            } label: {
                                RentalListingCardView(
                                    listing: listing,
                                    vm: currencyManager
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .navigationTitle("Favourites")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchFavoriteListings()
        }
    }
}
