//
//  MyListingsView.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-09-28.
//

import SwiftUI

struct MyListingsView: View {
    @StateObject private var viewModel = RentalListingsViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.listings) { listing in
                VStack(alignment: .leading, spacing: 6) {
                    Text(listing.title)
                        .font(.headline)
                    Text(listing.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("Posted on \(listing.datePosted.formatted(.dateTime.month().day().year()))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("My Listings")
            .onAppear {
                viewModel.fetchMyListings()
            }
        }
    }
}
