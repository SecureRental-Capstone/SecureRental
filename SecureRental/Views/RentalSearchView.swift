//
//  SearchBar.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2024-11-07.
//

// SearchBar.swift
import SwiftUI

struct RentalSearchView: View {
    @ObservedObject var viewModel: RentalListingsViewModel
    
    var body: some View {
        VStack {
            // Search bar
            TextField("Search listings...", text: $viewModel.searchText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding([.leading, .trailing])

            // Amenity filters
            HStack {
                ForEach(["WiFi", "Parking", "Pet-friendly", "Gym"], id: \.self) { amenity in
                    Toggle(isOn: Binding(
                        get: { viewModel.selectedAmenities.contains(amenity) },
                        set: { isSelected in
                            if isSelected {
                                viewModel.selectedAmenities.append(amenity)
                            } else {
                                viewModel.selectedAmenities.removeAll { $0 == amenity }
                            }
                        }
                    )) {
                        Text(amenity)
                    }
                    .toggleStyle(.button)
                    .padding(5)
                }
            }
            .padding()

            // Listings view
            List(viewModel.listings) { listing in
                NavigationLink(destination: RentalListingDetailView(listing: listing)) {
                    Text(listing.title)
                        .font(.headline)
                }
            }
        }
        .navigationTitle("Search Rentals")
        .onAppear{
            viewModel.shouldAutoFilter = true

//            viewModel.filterListings(searchTerm: viewModel.searchText, amenities: viewModel.selectedAmenities)
        }
    }
}

