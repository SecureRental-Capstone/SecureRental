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
    
    var body: some View {
        NavigationView {
            List($viewModel.listings) { $listing in
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
            .navigationTitle("My Listings")
            .onAppear {
                viewModel.fetchMyListings()
            }
            .sheet(item: $selectedListing) { listing in
                EditRentalListingView(viewModel: viewModel, listing: listing)
            }
        }
    }
}

