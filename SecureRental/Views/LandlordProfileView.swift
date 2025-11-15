//
//  LandlordProfileView.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-11-14.
//
import SwiftUI

struct LandlordProfileView: View {
    let landlord: AppUser

    @State private var listings: [Listing] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            // Background matches rest of app
            LinearGradient(
                colors: [
                    Color.hunterGreen.opacity(0.06),
                    Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
                // MARK: - Profile Card
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center, spacing: 12) {
                        UserRow(user: landlord)   // already styled avatar + name + rating
                        Spacer()
                    }

                    Text(profileSubtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.06),
                                radius: 4, x: 0, y: 2)
                )
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // MARK: - Listings Section
                if let errorMessage {
                    // Error card
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .font(.subheadline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.05),
                                    radius: 3, x: 0, y: 1)
                    )
                    .padding(.horizontal, 16)

                    Spacer()
                } else if isLoading {
                    // Skeletons
                    ScrollView {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Listings by \(landlord.name)")
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 16)
                                .padding(.top, 4)

                            LazyVStack(spacing: 10) {
                                ForEach(0..<4, id: \.self) { _ in
                                    SkeletonListingCardView()
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 10)
                        }
                    }
                } else if listings.isEmpty {
                    // Empty state
                    ScrollView {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Listings by \(landlord.name)")
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 16)
                                .padding(.top, 4)

                            Spacer(minLength: 40)

                            VStack(spacing: 8) {
                                Image(systemName: "tray")
                                    .font(.system(size: 30))
                                    .foregroundColor(.gray.opacity(0.6))

                                Text("No other listings from this landlord.")
                                    .font(.body)
                                    .foregroundColor(.primary)

                                Text("This landlord currently has no additional active listings.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }

                            Spacer()
                        }
                    }
                } else {
                    // Actual listings
                    ScrollView {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Listings by \(landlord.name)")
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 16)
                                .padding(.top, 4)

                            LazyVStack(spacing: 10) {
                                ForEach(listings, id: \.id) { listing in
                                    NavigationLink {
                                        RentalListingDetailView(listing: listing)
                                            .environmentObject(FireDBHelper.getInstance())
                                    } label: {
                                        ListingCardView(listing: listing)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 10)
                        }
                    }
                }
            }
        }
        .navigationTitle(landlord.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task { await loadListings() }
        }
    }

    // MARK: - Derived text

    private var profileSubtitle: String {
        if isLoading { return "Loading listings…" }
        let count = listings.count
        if count == 0 { return "This landlord has no other active listings yet." }
        if count == 1 { return "This landlord has 1 other active listing." }
        return "This landlord has \(count) other active listings."
    }

    // MARK: - Data

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
