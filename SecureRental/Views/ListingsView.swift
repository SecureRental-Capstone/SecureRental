//
//  ListingsView.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2024-11-14.
//
//

import SwiftUI

struct ListingsView: View {
    @ObservedObject var viewModel: RentalListingsViewModel

    var body: some View {
        NavigationView {
            VStack {

                // Amenities Filter (optional, if you want to include here)


                // Listings List
                List(viewModel.listings) { listing in
                    NavigationLink(destination: RentalListingDetailView(listing: listing)) {

                        HStack {
                            ForEach(listing.images, id: \.self) { image in
                                Image(uiImage: image)
                                      .resizable()
                                      .scaledToFit()
                                      .frame(width: 100, height: 100)
                                      .cornerRadius(8)
                                
                            }

                            VStack(alignment: .leading) {
                                Text(listing.title)
                                    .font(.headline)
                                Text(listing.price)
                                    .font(.subheadline)
                            }
                            Spacer()
                            Button(action: {
                                viewModel.updateListing(listing)
                                // Optionally navigate to edit view
                            }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }
                .navigationTitle("Rental Listings")

            }
        }
    }
}

struct ListingsView_Previews: PreviewProvider {
    static var previews: some View {
        ListingsView(viewModel: RentalListingsViewModel())
    }
}
