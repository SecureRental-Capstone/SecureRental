//
//  LandlordProfileView.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-11-14.
//
import SwiftUI

import SwiftUI

struct LandlordProfileView: View {
    let landlord: AppUser

    @State private var listings: [Listing] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        List {
            // Top profile section
            Section {
                UserRow(user: landlord)
            } header: {
                Text("Profile")
            }

            // Listings section
            Section(header: Text("Listings by \(landlord.name)")) {
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                ForEach(listings, id: \.id) { listing in
                    NavigationLink {
                        RentalListingDetailView(listing: listing)
                            .environmentObject(FireDBHelper.getInstance())
                    } label: {
                        HStack(spacing: 12) {
                            if let firstURL = listing.imageURLs.first,
                               let url = URL(string: firstURL) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 60, height: 60)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 60)
                                            .clipped()
                                            .cornerRadius(8)
                                    case .failure:
                                        Image(systemName: "house")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 60, height: 60)
                                            .foregroundColor(.gray)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                Image(systemName: "house")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.gray)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(listing.title)
                                    .font(.headline)
                                    .lineLimit(1)

                                Text("$\(listing.price)/month")
                                    .font(.subheadline)

                                Text("\(listing.city), \(listing.province)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                if isLoading && listings.isEmpty && errorMessage == nil {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }

                if !isLoading && listings.isEmpty && errorMessage == nil {
                    Text("No other listings from this landlord.")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle(landlord.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task { await loadListings() }
        }
    }

    private func loadListings() async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await FireDBHelper.getInstance().fetchListings(for: landlord.id)
            await MainActor.run {
                self.listings = result
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load listings."
                self.isLoading = false
            }
            print("❌ Failed to load landlord listings: \(error.localizedDescription)")
        }
    }
}

