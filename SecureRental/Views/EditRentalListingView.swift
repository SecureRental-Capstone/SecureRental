//
//  EditRentalListingView.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2024-11-07.
//

import SwiftUI
import PhotosUI

struct EditRentalListingView: View {
    @ObservedObject var viewModel: RentalListingsViewModel
    var listing: Listing
    @State private var title: String
    @State private var description: String
    @State private var price: String
    @State private var street: String
    @State private var city: String
    @State private var province: String
    @State private var numberOfBedrooms: Int
    @State private var numberOfBathrooms: Int
    @State private var selectedAmenities: [String]
    @State private var isAvailable: Bool
//    @State private var selectedImage: [UIImage] // Image selection
    
    // Photos picker
    @State private var isShowingImagePicker = false
    @State private var selectedImageData: UIImage?

    init(viewModel: RentalListingsViewModel, listing: Listing) {
        self.viewModel = viewModel
        self.listing = listing
        _title = State(initialValue: listing.title)
        _description = State(initialValue: listing.description)
        _price = State(initialValue: listing.price)
        
        let locationComponents = listing.location.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        _street = State(initialValue: locationComponents.count > 0 ? String(locationComponents[0]) : "")
        _city = State(initialValue: locationComponents.count > 1 ? String(locationComponents[1]) : "")
        _province = State(initialValue: locationComponents.count > 2 ? String(locationComponents[2]) : "")
        
        _numberOfBedrooms = State(initialValue: listing.numberOfBedrooms)
        _numberOfBathrooms = State(initialValue: listing.numberOfBathrooms)
        _selectedAmenities = State(initialValue: listing.amenities)
        _isAvailable = State(initialValue: listing.isAvailable)
    }

    var body: some View {
        Form {
            Section(header: Text("Basic Info")) {
                TextField("Title", text: $title)
                TextField("Description", text: $description)
                TextField("Price", text: $price)
            }

            Section(header: Text("Location")) {
                TextField("Street", text: $street)
                TextField("City", text: $city)
                TextField("Province", text: $province)
            }

            Section(header: Text("Details")) {
                Stepper("Bedrooms: \(numberOfBedrooms)", value: $numberOfBedrooms, in: 0...10)
                Stepper("Bathrooms: \(numberOfBathrooms)", value: $numberOfBathrooms, in: 0...10)
            }

            Section(header: Text("Amenities")) {
                ForEach(["WiFi", "Parking", "Pet-friendly", "Gym"], id: \.self) { amenity in
                    Toggle(isOn: Binding(
                        get: { selectedAmenities.contains(amenity) },
                        set: { isSelected in
                            if isSelected {
                                selectedAmenities.append(amenity)
                            } else {
                                selectedAmenities.removeAll { $0 == amenity }
                            }
                        }
                    )) {
                        Text(amenity)
                    }
                }
            }
            
            Section {
                Toggle(isOn: $isAvailable) {
                    Text("Available")
                }
            }

//            Section(header: Text("Image")) {
//                if let selectedImage = selectedImage {
//                    Image(uiImage: selectedImage)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(height: 200)
//                        .cornerRadius(10)
//                } else {
//                    Text("No Image Selected")
//                }
//
//                Button("Select Image") {
//                    isShowingImagePicker = true
//                }
//            }

            Button(action: {
                saveChanges()
            }) {
                Text("Save Changes")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .navigationTitle("Edit Listing")
//        .sheet(isPresented: $isShowingImagePicker) {
//            ImagePicker(images: $selectedImage)
//                }
    }

    private func saveChanges() {
        let updatedListing = Listing(
//            id: listing.id,
            title: title,
            description: description,
            price: price,
//            images: selectedImageData != nil ? "uploadedImage" : listing.images,
            images: [selectedImageData ?? UIImage()],
            location: "\(street), \(city), \(province)",
            isAvailable: listing.isAvailable,
            datePosted: listing.datePosted,
            numberOfBedrooms: numberOfBedrooms,
            numberOfBathrooms: numberOfBathrooms,
            squareFootage: listing.squareFootage,
            amenities: selectedAmenities,
            street: street,
            city: city,
            province: province
        )
        
        viewModel.updateListing(updatedListing)
    }
}

