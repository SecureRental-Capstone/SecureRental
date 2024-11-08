//
//  EditRentalListingView.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2024-11-07.
//

import SwiftUI

struct EditRentalListingView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: RentalListingsViewModel
    var listing: RentalListing
    
    @State private var title: String
    @State private var description: String
    @State private var price: String
    @State private var location: String
    @State private var numberOfBedrooms: String
    @State private var numberOfBathrooms: String
    @State private var squareFootage: String
    @State private var amenities: String
    @State private var imageName: String
    @State private var isAvailable: Bool
    
    init(viewModel: RentalListingsViewModel, listing: RentalListing) {
        self.viewModel = viewModel
        self.listing = listing
        _title = State(initialValue: listing.title)
        _description = State(initialValue: listing.description)
        _price = State(initialValue: listing.price)
        _location = State(initialValue: listing.location)
        _numberOfBedrooms = State(initialValue: "\(listing.numberOfBedrooms)")
        _numberOfBathrooms = State(initialValue: "\(listing.numberOfBathrooms)")
        _squareFootage = State(initialValue: "\(listing.squareFootage)")
        _amenities = State(initialValue: listing.amenities.joined(separator: ", "))
        _imageName = State(initialValue: listing.imageName)
        _isAvailable = State(initialValue: listing.isAvailable)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Property Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    TextField("Price", text: $price)
                    TextField("Location", text: $location)
                    TextField("Bedrooms", text: $numberOfBedrooms)
                        .keyboardType(.numberPad)
                    TextField("Bathrooms", text: $numberOfBathrooms)
                        .keyboardType(.numberPad)
                    TextField("Square Footage", text: $squareFootage)
                        .keyboardType(.numberPad)
                    TextField("Amenities (comma separated)", text: $amenities)
                }
                
                Section(header: Text("Media")) {
                    // Implement media upload functionality here
                    Text("Media Upload Feature Coming Soon")
                }
                
                Section {
                    Toggle(isOn: $isAvailable) {
                        Text("Available")
                    }
                }
            }
            .navigationBarTitle("Edit Listing", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                saveChanges()
                presentationMode.wrappedValue.dismiss()
            }.disabled(!isFormValid()))
        }
    }
    
    private func isFormValid() -> Bool {
        return !title.isEmpty && !description.isEmpty && !price.isEmpty && !location.isEmpty && Int(numberOfBedrooms) != nil && Int(numberOfBathrooms) != nil && Int(squareFootage) != nil
    }
    
    private func saveChanges() {
        var updatedListing = listing
        updatedListing.title = title
        updatedListing.description = description
        updatedListing.price = price
        updatedListing.location = location
        updatedListing.numberOfBedrooms = Int(numberOfBedrooms) ?? 0
        updatedListing.numberOfBathrooms = Int(numberOfBathrooms) ?? 0
        updatedListing.squareFootage = Int(squareFootage) ?? 0
        updatedListing.amenities = amenities.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        updatedListing.isAvailable = isAvailable
        
        viewModel.updateListing(updatedListing)
    }
}

