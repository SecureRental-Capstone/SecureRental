//
//  HomeView.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2024-10-19.


import SwiftUI
import FirebaseAuth



extension Color {

    static let hunterGreen = Color(red: 0.21, green: 0.67, blue: 0.23)
}



struct SkeletonListingCardView: View {
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primaryPurple.opacity(0.12))
                .frame(width: 110, height: 90)

            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 14)

                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 10)

                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.18))
                    .frame(width: 110, height: 8)
            }

            Spacer()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
        )
        .shimmer()
    }
}



struct ListingCardView: View {
    let listing: Listing

    var body: some View {
        HStack(spacing: 12) {
            // Fixed-size thumbnail
            ZStack {
                if let firstURL = listing.imageURLs.first,
                   let url = URL(string: firstURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            Image(systemName: "house.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.gray.opacity(0.7))
                                .padding(12)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "house.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray.opacity(0.7))
                        .padding(12)
                }
            }
            .frame(width: 110, height: 90)          // 👈 consistent size
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Text block
            VStack(alignment: .leading, spacing: 4) {
                Text(listing.title)
                    .font(.footnote.weight(.semibold)) // smaller
                    .lineLimit(2)

                Text("$\(listing.price)/month")
                    .font(.caption.weight(.semibold))  // smaller + bold
                    .foregroundColor(.primaryPurple)

                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(listing.city), \(listing.province)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        )
    }
}

