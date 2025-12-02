//
//  MyListingsView.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-09-28.
//

import SwiftUI
import FirebaseAuth

struct MyListingsView: View {
    @StateObject private var viewModel = RentalListingsViewModel()
    @State private var selectedListing: Listing?
    @EnvironmentObject var dbHelper: FireDBHelper
    @EnvironmentObject var currencyManager: CurrencyViewModel
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.listings.isEmpty {
                    // 👉 Empty state
                    VStack(spacing: 10) {
                        Image(systemName: "house")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.6))
                        Text("You haven't posted any listings yet.")
                            .font(.headline)
                        Text("Tap the + button on Home to create your first rental listing.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // 👉 Your original list
                    List($viewModel.listings) { $listing in
                        NavigationLink(
                            destination: RentalListingDetailView(listing: listing).environmentObject(currencyManager)
                                .environmentObject(dbHelper)
                        ) {
                            HStack {
                                if let firstImage = listing.imageURLs.first {
                                    AsyncImage(url: URL(string: firstImage)) { image in
                                        image.resizable().scaledToFill()
                                    } placeholder: {
                                        Color.gray.opacity(0.3)
                                    }
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(8)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(listing.title)
                                        .font(.headline)
                                    Text(listing.description)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("Posted on \(listing.datePosted.formatted(.dateTime.month().day().year()))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Button(action: { selectedListing = listing }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("My Listings")
            .onAppear {
                viewModel.shouldAutoFilter = false
                viewModel.fetchMyListings()
                // viewModel.filterListings(searchTerm: "", amenities: [], showOnlyAvailable: false)
            }
            .sheet(item: $selectedListing) { listing in
                EditRentalListingView(viewModel: viewModel, listing: listing)
            }
        }
    }
}
