////
////  FilterView.swift
////  SecureRental
////
////  Created by Haniya Akhtar on 2025-11-18.
////
import SwiftUI

struct FilterCardView: View {
    @Binding var isVisible: Bool

    // Temporary state for the filters
    @State private var tempMaxPrice: Double
    @State private var tempSelectedBedrooms: Int?
    @State private var tempShowVerifiedOnly: Bool
    
    // Amenity State Variables
    @State private var tempHasWifi: Bool
    @State private var tempHasParking: Bool
    @State private var tempIsPetFriendly: Bool
    @State private var tempHasGym: Bool

    @EnvironmentObject var currencyManager: CurrencyViewModel
    @EnvironmentObject var viewModel: RentalListingsViewModel

    // Parent closures
    var applyAction: (Double, Int?, Bool, Bool, Bool, Bool, Bool) -> Void
    var resetAction: () -> Void
    var onLocationClick: () -> Void

    // Initializer to load parent values into temp
    init(
        isVisible: Binding<Bool>,
        maxPrice: Double,
        selectedBedrooms: Int?,
        showVerifiedOnly: Bool,
        hasWifi: Bool,
        hasParking: Bool,
        isPetFriendly: Bool,
        hasGym: Bool,
        applyAction: @escaping (Double, Int?, Bool, Bool, Bool, Bool, Bool) -> Void,
        resetAction: @escaping () -> Void,
        onLocationClick: @escaping () -> Void
    ) {
        _isVisible = isVisible
        self.applyAction = applyAction
        self.resetAction = resetAction
        self.onLocationClick = onLocationClick

        _tempMaxPrice = State(initialValue: maxPrice)
        _tempSelectedBedrooms = State(initialValue: selectedBedrooms)
        _tempShowVerifiedOnly = State(initialValue: showVerifiedOnly)
        
        _tempHasWifi = State(initialValue: hasWifi)
        _tempHasParking = State(initialValue: hasParking)
        _tempIsPetFriendly = State(initialValue: isPetFriendly)
        _tempHasGym = State(initialValue: hasGym)
    }

    var body: some View {
        VStack(spacing: 20) {

            // HEADER
            HStack {
                Text("Filters")
                    .font(.title3.weight(.semibold))
                Spacer()
                Button {
                    withAnimation { isVisible = false }
                } label: {
                    Image(systemName: "xmark")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            }
            .padding(.bottom, 4)

            // --- Price Slider ---
            VStack(alignment: .leading, spacing: 8) {
                Text("Max Price")
                    .font(.subheadline.weight(.semibold))

                HStack {
                    Text(currencyManager.convertedPrice(basePriceString: "0"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(currencyManager.convertedPrice(basePriceString: "\(Int(tempMaxPrice))"))
                        .font(.caption.weight(.semibold))
                        .foregroundColor(Color(red: 0.1, green: 0.5, blue: 0.2)) // Dark green price color
                }

                Slider(
                    value: $tempMaxPrice,
                    in: 0...5000,
                    step: 50
                )
                .tint(Color(red: 0.1, green: 0.5, blue: 0.2))
            }

            Divider()

            // Location button (same logic, green UI)
            Button(action: {
                isVisible = false   // close filter card first
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    onLocationClick()   // trigger navigation
                }
            }) {
                HStack {
                    Image(systemName: "location.fill")
                    Text("Set My Location")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
//                .background(Color(red: 0.1, green: 0.5, blue: 0.2)) // Dark green price color
                .background(.blue) // Dark green price color
                .cornerRadius(12)
            }
            .padding(.horizontal, 4)

            Divider()

            // --- Bedrooms ---
            VStack(alignment: .leading, spacing: 8) {
                Text("Bedrooms")
                    .font(.subheadline.weight(.semibold))
                HStack {
                    filterButton(title: "Any", isSelected: tempSelectedBedrooms == nil) {
                        tempSelectedBedrooms = nil
                    }
                    filterButton(title: "1", isSelected: tempSelectedBedrooms == 1) {
                        tempSelectedBedrooms = 1
                    }
                    filterButton(title: "2", isSelected: tempSelectedBedrooms == 2) {
                        tempSelectedBedrooms = 2
                    }
                    filterButton(title: "3+", isSelected: tempSelectedBedrooms == 3) {
                        tempSelectedBedrooms = 3
                    }
                }
            }

            Divider()
            
            // --- Amenities ---
            VStack(alignment: .leading, spacing: 8) {
                Text("Amenities")
                    .font(.subheadline.weight(.semibold))
                
                HStack {
                    amenityButton(title: "Wi-Fi", icon: "wifi", isSelected: tempHasWifi) {
                        tempHasWifi.toggle()
                    }
                    
                    amenityButton(title: "Parking", icon: "car.fill", isSelected: tempHasParking) {
                        tempHasParking.toggle()
                    }
                }
                
                HStack {
                    amenityButton(title: "Pet-Friendly", icon: "pawprint.fill", isSelected: tempIsPetFriendly) {
                        tempIsPetFriendly.toggle()
                    }
                    
                    amenityButton(title: "Gym", icon: "figure.strengthtraining.traditional", isSelected: tempHasGym) {
                        tempHasGym.toggle()
                    }
                    Spacer()
                }
            }
            
            Divider()

            // ACTION BUTTONS
            HStack(spacing: 16) {

                // RESET
                Button {
                    tempMaxPrice = 5000
                    tempSelectedBedrooms = nil
                    tempShowVerifiedOnly = false
                    
                    tempHasWifi = false
                    tempHasParking = false
                    tempIsPetFriendly = false
                    tempHasGym = false
                    
                    resetAction()
                    withAnimation { isVisible = false }

                } label: {
                    Text("Reset")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(Color(red: 0.1, green: 0.5, blue: 0.2)) // Dark green price color
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(red: 0.1, green: 0.5, blue: 0.2), lineWidth: 1.5)
                        )
                }

                // APPLY
                Button {
                    applyAction(
                        tempMaxPrice,
                        tempSelectedBedrooms,
                        tempShowVerifiedOnly,
                        tempHasWifi,
                        tempHasParking,
                        tempIsPetFriendly,
                        tempHasGym
                    )
                    withAnimation { isVisible = false }

                } label: {
                    Text("Apply Filters")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color(red: 0.1, green: 0.5, blue: 0.2)) // Dark green price color
                        .cornerRadius(10)
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.15), radius: 20, y: 8)
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }

    // Bedroom button helper
    @ViewBuilder
    private func filterButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.medium))
                .frame(minWidth: 52)
                .padding(.vertical, 8)
                .background(
                    isSelected
                    ? Color(red: 0.1, green: 0.5, blue: 0.2)
                    : Color(.systemGray6)
                )
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
    }
    
    // Amenity button helper
    @ViewBuilder
    private func amenityButton(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected
                ? Color(red: 0.1, green: 0.5, blue: 0.2)
                : Color(.systemGray6)
            )
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
    
    private var maxListingCAD: Double {
        viewModel.locationListings
            .compactMap { Double($0.price.filter("0123456789.".contains)) }
            .max() ?? 5000
    }
}
