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
                .onAppear{
                    viewModel.fetchListings() // ✅ Load all listings to match favourites
                    viewModel.fetchFavoriteListings()

                }
            }
        }
    }
}


