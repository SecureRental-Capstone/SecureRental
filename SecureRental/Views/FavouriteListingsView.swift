//
//  FavouriteListingsView.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2024-11-14.
//

import SwiftUI

struct FavouriteListingsView: View {
    @ObservedObject var viewModel: RentalListingsViewModel
    @EnvironmentObject var dbHelper: FireDBHelper
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background consistent with app
                LinearGradient(
                    colors: [
                        Color.hunterGreen.opacity(0.06),
                        Color(.systemBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                Divider()
                
                if viewModel.favouriteListings.isEmpty {
                    // MARK: - Empty state
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
                    // MARK: - Favourites list (cards)
                    ScrollView {
                        VStack(alignment: .leading, spacing: 6) {
                            LazyVStack(spacing: 10) {
                                ForEach(viewModel.favouriteListings) { listing in
                                    
                                    ZStack(alignment: .topTrailing) {
                                        // Main navigation to detail
                                        NavigationLink {
                                            RentalListingDetailView(listing: listing)
                                                .environmentObject(dbHelper)
                                        } label: {
                                            ListingCardView(listing: listing)
                                        }
                                        .buttonStyle(.plain)
                                        
                                        // Heart toggle
                                        Button {
                                            viewModel.toggleFavorite(for: listing)
                                        } label: {
                                            Image(systemName: viewModel.isFavorite(listing) ? "heart.fill" : "heart")
                                                .font(.system(size: 16, weight: .semibold))
                                                .padding(8)
                                                .background(
                                                    Circle()
                                                        .fill(Color.white.opacity(0.9))
                                                        .shadow(color: .black.opacity(0.15),
                                                                radius: 3, x: 0, y: 1)
                                                )
                                                .foregroundColor(.red)
                                        }
                                        .padding(10)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 10)
                        }
                    }
                }
            }
            .navigationTitle("Favourites")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            viewModel.fetchFavoriteListings()
            // Optional: also refresh listings, if you want this page to be independent
            // viewModel.fetchListings()
        }
    }
}

