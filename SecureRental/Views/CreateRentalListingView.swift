
//
//  CreateRentalListingView.swift
//  SecureRental
//
//  Created by Anchal Sharma on 2024-11-07.
//
//
//


import SwiftUI
import FirebaseAuth

struct CreateRentalListingView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: RentalListingsViewModel
    
    // Rental listing state properties
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var price: String = ""
    @State private var numberOfBedrooms: Int = 0
    @State private var numberOfBathrooms: Int = 0
    @State private var squareFootage: String = ""
    
    // New location fields
    @State private var street: String = ""
    @State private var city: String = ""
    @State private var province: String = ""
    
    // Amenities and custom amenity
    @State private var selectedAmenities: [String] = []
    @State private var customAmenity: String = ""
    let defaultAmenities = ["WiFi", "Parking", "Pet Friendly", "Gym Access"]
    
    // Image upload state
    @State private var images: [UIImage] = []
    @State private var isAvailable: Bool = true
    
    var body: some View {
        NavigationView {
            Form {
                // Property details section
                Section(header: Text("Property Details")) {
                    TextFieldWithRequiredIndicator(placeholder: "Title", text: $title)
                    TextFieldWithRequiredIndicator(placeholder: "Description", text: $description)
                    TextFieldWithRequiredIndicator(placeholder: "Price per month", text: $price)
                        .keyboardType(.decimalPad)
                    TextFieldWithRequiredIndicator(placeholder: "Square Footage", text: $squareFootage)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Details")) {
                    Stepper("Bedrooms: \(numberOfBedrooms)", value: $numberOfBedrooms, in: 0...100)
                    Stepper("Bathrooms: \(numberOfBathrooms)", value: $numberOfBathrooms, in: 0...100)
                }
                
                // Location section
                Section(header: Text("Location Details")) {
                    TextFieldWithRequiredIndicator(placeholder: "Street", text: $street)
                    TextFieldWithRequiredIndicator(placeholder: "City", text: $city)
                    TextFieldWithRequiredIndicator(placeholder: "Province", text: $province)
                }
                
                // Amenities section with checkboxes and custom input
                Section(header: Text("Amenities")) {
                    ForEach(defaultAmenities, id: \.self) { amenity in
                        Toggle(amenity, isOn: Binding(
                            get: { selectedAmenities.contains(amenity) },
                            set: { isSelected in
                                if isSelected {
                                    selectedAmenities.append(amenity)
                                } else {
                                    selectedAmenities.removeAll { $0 == amenity }
                                }
                            }
                        ))
                    }
                    TextField("Custom Amenity", text: $customAmenity)
                }
                
                // Image upload section
                Section(header: Text("Upload Image").modifier(RequiredField())) {
                    ImagePicker(images: $images)
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
        return !title.isEmpty && !description.isEmpty && !price.isEmpty &&
               !street.isEmpty && !city.isEmpty && !province.isEmpty  &&
               !squareFootage.isEmpty && !images.isEmpty
    }
    
    private func saveListing() {
        guard let landlordId = Auth.auth().currentUser?.uid else { return }

        let newListing = Listing(
                title: title,
                description: description,
                price: price,
                imageURLs: [], // will be filled after upload
                location: "\(street), \(city), \(province)",
                isAvailable: isAvailable,
                numberOfBedrooms: numberOfBedrooms,
                numberOfBathrooms: numberOfBathrooms,
                squareFootage: Int(squareFootage) ?? 0,
                amenities: selectedAmenities + (customAmenity.isEmpty ? [] : [customAmenity]),
                street: street,
                city: city,
                province: province,
                datePosted: Date(),
                landlordId: landlordId
            )
            
            viewModel.addListing(newListing, images: images)
    }

}

// Custom modifier for required fields
struct RequiredField: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(Text("*").foregroundColor(.red).offset(x: 8, y: -8), alignment: .trailing)
    }
}

struct TextFieldWithRequiredIndicator: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .modifier(RequiredField())
    }
}
