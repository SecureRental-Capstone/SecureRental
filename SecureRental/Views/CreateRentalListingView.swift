//
//  CreateRentalListingView.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2024-11-07.
//

import SwiftUI
import CoreLocation

struct CreateRentalListingView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: RentalListingsViewModel
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var price: String = ""
    @State private var location: String = ""
    @State private var numberOfBedrooms: String = ""
    @State private var numberOfBathrooms: String = ""
    @State private var squareFootage: String = ""
    @State private var amenities: String = ""
    @State private var imageName: String = "defaultImage" // Placeholder
    @State private var isAvailable: Bool = true
    @State private var latitude: String = "" // New latitude field
    @State private var longitude: String = "" // New longitude field
    
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
                
                Section(header: Text("Location Coordinates")) {
                    TextField("Latitude", text: $latitude)
                        .keyboardType(.decimalPad)
                    TextField("Longitude", text: $longitude)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Media")) {
                    Text("Media Upload Feature Coming Soon")
                }
                
                Section {
                    Toggle(isOn: $isAvailable) {
                        Text("Available")
                    }
                }
            }
            .navigationBarTitle("Create Listing", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                saveListing()
                presentationMode.wrappedValue.dismiss()
            }.disabled(!isFormValid()))
        }
    }
    
    private func isFormValid() -> Bool {
        return !title.isEmpty && !description.isEmpty && !price.isEmpty && !location.isEmpty &&
               Int(numberOfBedrooms) != nil && Int(numberOfBathrooms) != nil && Int(squareFootage) != nil &&
               Double(latitude) != nil && Double(longitude) != nil
    }
    
    private func saveListing() {
        let newListing = RentalListing(
            title: title,
            description: description,
            price: price,
            imageName: imageName,
            location: location,
            isAvailable: isAvailable,
            datePosted: Date(),
            numberOfBedrooms: Int(numberOfBedrooms) ?? 0,
            numberOfBathrooms: Int(numberOfBathrooms) ?? 0,
            squareFootage: Int(squareFootage) ?? 0,
            amenities: amenities.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            coordinates: CLLocationCoordinate2D(latitude: Double(latitude) ?? 0, longitude: Double(longitude) ?? 0)
        )
        viewModel.addListing(newListing)
    }
}

struct CreateRentalListingView_Previews: PreviewProvider {
    static var previews: some View {
        CreateRentalListingView(viewModel: RentalListingsViewModel())
    }
}
