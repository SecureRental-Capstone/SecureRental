import SwiftUI

struct RentalSearchView: View {
    @ObservedObject var viewModel: RentalListingsViewModel
    @EnvironmentObject var currencyManager: CurrencyViewModel

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

            // Listings view with loading indicator
            if viewModel.isLoading {
                Spacer()
                ProgressView("Fetching listings...")
                    .padding()
                Spacer()
            } else {
                List(viewModel.locationListings) { listing in
                    NavigationLink(destination: RentalListingDetailView(listing: listing).environmentObject(currencyManager)) {
                        Text(listing.title)
                            .font(.headline)
                    }
                }
            }
        }
        .navigationTitle("Search Rentals")
        .onAppear {
            viewModel.shouldAutoFilter = true
            Task {
                await viewModel.loadHomePageListings(forceReload: true) // fetch fresh listings
            }
        }
    }
}
