//
//  FavouriteListingsView.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2024-11-14.
//

import SwiftUI

struct FavouriteListingsView: View {
    @ObservedObject var viewModel: RentalListingsViewModel
    
    var body: some View {
        NavigationView {
            if viewModel.favouriteListings.isEmpty {
                VStack {
                    Text("No Favorites Yet")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Add some listings to your favorites to see them here.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else {
                List(viewModel.favouriteListings) { listing in
                    NavigationLink(destination: RentalListingDetailView(listing: listing)) {
                        HStack {
                                // Placeholder for an image (or use actual listing images if available)
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                )
                            
                            VStack(alignment: .leading) {
                                Text(listing.title)
                                    .font(.headline)
                                    .lineLimit(1)
                                Text("\(listing.city), \(listing.province)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("$\(listing.price)/month")
                                    .font(.footnote)
                                    .foregroundColor(.blue)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 5)
                    }
                }
                .navigationTitle("Favorites")
            }
        }
    }
}


