//
//  RentalListingCardView.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2025-11-18.
//

import SwiftUI

/// A single reusable card view for a rental listing.
struct RentalListingCardView: View {
    // Requires Listing (Models.swift) and CurrencyViewModel (CurrencyViewModel.swift)
    let listing: Listing
    @ObservedObject var vm: CurrencyViewModel
    
    @EnvironmentObject var viewModel: RentalListingsViewModel

//    @StateObject var viewModel = RentalListingsViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // MARK: Image and Overlays
            ZStack(alignment: .top) {
                // Image
                AsyncImage(url: URL(string: listing.imageURLs.first ?? "")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color(.systemGray4)
                }
                .frame(height: 220)
                .clipped()
                
                // Badges (Top Left & Top Right)
                HStack {
                    // Verified Badge
//                    if listing.isAvailable { //should be is verified
//                        Text("Verified")
//                            .font(.caption2.bold())
//                            .foregroundColor(.white)
//                            .padding(.horizontal, 8)
//                            .padding(.vertical, 4)
//                            .background(Color.green)
//                            .cornerRadius(10)
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 10)
//                                    .stroke(Color.white, lineWidth: 1)
//                            )
//                    }
                    
                    Spacer()
                    
                    // Heart Icon
//                    Button {
//                        // Action to favorite
//                    } label: {
//                        Image(systemName: "heart.fill")
//                            .padding(8)
//                            .background(Color.white)
//                            .clipShape(Circle())
//                            .foregroundColor(.red) // Red for favorited, gray for unfavorited
//                    }
                    Button {
                        withAnimation(.spring()) {
                            viewModel.toggleFavorite(for: listing) // listing is the item you want to favorite
                        }
                    } label: {
                        Image(systemName: viewModel.isFavorite(listing) ? "heart.fill" : "heart")
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                            .foregroundColor(viewModel.isFavorite(listing) ? .red : .gray)
                    }

                }
                .padding(12)
            }
            // Uses the extension from Extensions.swift
            .cornerRadius(15, corners: [.topLeft, .topRight])
            
            // MARK: Details
            VStack(alignment: .leading, spacing: 6) {
                // Title and Price (HStack)
                HStack(alignment: .top) {
                    Text(listing.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Converted Price - uses the logic from CurrencyViewModel
                    Text(vm.convertedPrice(basePriceString: listing.price) + "/mo")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(Color(red: 0.1, green: 0.5, blue: 0.2)) // Dark green price color
                }
                
//                // Location
//                HStack(spacing: 4) {
//                    Image(systemName: "location.fill")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                    Text(listing.location)
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                }
                
                // Proximity Pill
                Text(listing.location)
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(6)
                
                // Bed/Bath Details
                HStack {
                    Image(systemName: "bed.double.fill")
                    Text("\(listing.numberOfBedrooms) bed")
                    
                    Text("|")
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Image(systemName: "bathtub.fill")
                    Text("\(listing.numberOfBathrooms) bath")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

