////
////  FilterView.swift
////  SecureRental
////
////  Created by Haniya Akhtar on 2025-11-18.
////
import SwiftUI

//struct FilterCardView: View {
//    @Binding var isVisible: Bool
//    @Binding var priceRange: ClosedRange<Double>
//    @Binding var selectedBedrooms: Int?
//    @Binding var showVerifiedOnly: Bool
//    
//    var applyAction: () -> Void
//    var resetAction: () -> Void
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            HStack {
//                Text("Filters")
//                    .font(.title2.weight(.bold))
//                Spacer()
//                Button {
//                    withAnimation { isVisible = false }
//                } label: {
//                    Image(systemName: "xmark")
//                        .foregroundColor(.primary)
//                        .padding(8)
//                        .background(Color(.systemGray5))
//                        .clipShape(Circle())
//                }
//            }
//            .padding(.bottom, 10)
//            
//            // Price range
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Price Range")
//                    .font(.headline)
//                HStack {
//                    Text("$\(Int(priceRange.lowerBound))")
//                    Spacer()
//                    Text("$\(Int(priceRange.upperBound))")
//                }
//                RangeSlider(range: $priceRange, bounds: 600...5000, step: 50)
//                    .frame(height: 50)
//            }
//            
//            // Bedrooms
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Bedrooms")
//                    .font(.headline)
//                HStack {
//                    filterButton(title: "Any", isSelected: selectedBedrooms == nil) { selectedBedrooms = nil }
//                    filterButton(title: "1", isSelected: selectedBedrooms == 1) { selectedBedrooms = 1 }
//                    filterButton(title: "2", isSelected: selectedBedrooms == 2) { selectedBedrooms = 2 }
//                    filterButton(title: "3+", isSelected: selectedBedrooms == 3) { selectedBedrooms = 3 }
//                }
//            }
//            
//            Toggle(isOn: $showVerifiedOnly) {
//                Text("Verified Properties Only")
//                    .font(.headline)
//            }
//            
//            HStack(spacing: 20) {
//                Button {
//                    resetAction()
//                } label: {
//                    Text("Reset")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .foregroundColor(.blue)
//                        .background(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color.blue, lineWidth: 2)
//                        )
//                }
//                
//                Button {
//                    applyAction()
//                } label: {
//                    Text("Apply Filters")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .foregroundColor(.white)
//                        .background(Color.blue)
//                        .cornerRadius(10)
//                }
//            }
//        }
//        .padding()
//        .background(Color(.systemBackground))
//        .cornerRadius(16)
//        .shadow(radius: 20)
//        .padding()
//    }
//    
//    @ViewBuilder
//    private func filterButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
//        Button(action: action) {
//            Text(title)
//                .frame(minWidth: 50)
//                .padding(.vertical, 8)
//                .background(isSelected ? Color.blue : Color(.systemGray5))
//                .foregroundColor(isSelected ? .white : .primary)
//                .cornerRadius(8)
//        }
//    }
//}
//struct FilterCardView: View {
//    @Binding var isVisible: Bool
//
//    // Temporary state for the filters
//    @State private var tempPriceRange: ClosedRange<Double>
//    @State private var tempSelectedBedrooms: Int?
//    @State private var tempShowVerifiedOnly: Bool
//
//    // Parent closures
//    var applyAction: (ClosedRange<Double>, Int?, Bool) -> Void
//    var resetAction: () -> Void
//
//    // Initializer to capture parent values into temp state
//    init(isVisible: Binding<Bool>,
//         priceRange: ClosedRange<Double>,
//         selectedBedrooms: Int?,
//         showVerifiedOnly: Bool,
//         applyAction: @escaping (ClosedRange<Double>, Int?, Bool) -> Void,
//         resetAction: @escaping () -> Void) {
//        
//        _isVisible = isVisible
//        self.applyAction = applyAction
//        self.resetAction = resetAction
//
//        _tempPriceRange = State(initialValue: priceRange)
//        _tempSelectedBedrooms = State(initialValue: selectedBedrooms)
//        _tempShowVerifiedOnly = State(initialValue: showVerifiedOnly)
//    }
//
//    var body: some View {
//        VStack(spacing: 20) {
//            // Header
//            HStack {
//                Text("Filters")
//                    .font(.title2.weight(.bold))
//                Spacer()
//                Button {
//                    withAnimation { isVisible = false }
//                } label: {
//                    Image(systemName: "xmark")
//                        .foregroundColor(.primary)
//                        .padding(8)
//                        .background(Color(.systemGray5))
//                        .clipShape(Circle())
//                }
//            }
//            .padding(.bottom, 10)
//
//            // Price Range
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Price Range")
//                    .font(.headline)
//                HStack {
//                    Text("$\(Int(tempPriceRange.lowerBound))")
//                    Spacer()
//                    Text("$\(Int(tempPriceRange.upperBound))")
//                }
//                RangeSlider(range: $tempPriceRange, bounds: 600...5000, step: 50)
//                    .frame(height: 50)
//            }
//
//            // Bedrooms
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Bedrooms")
//                    .font(.headline)
//                HStack {
//                    filterButton(title: "Any", isSelected: tempSelectedBedrooms == nil) { tempSelectedBedrooms = nil }
//                    filterButton(title: "1", isSelected: tempSelectedBedrooms == 1) { tempSelectedBedrooms = 1 }
//                    filterButton(title: "2", isSelected: tempSelectedBedrooms == 2) { tempSelectedBedrooms = 2 }
//                    filterButton(title: "3+", isSelected: tempSelectedBedrooms == 3) { tempSelectedBedrooms = 3 }
//                }
//            }
//
//            // Verified toggle
//            Toggle(isOn: $tempShowVerifiedOnly) {
//                Text("Verified Properties Only")
//                    .font(.headline)
//            }
//
//            // Buttons
//            HStack(spacing: 20) {
//                Button {
//                    // Reset both temp state and parent state
//                    tempPriceRange = 600...5000
//                    tempSelectedBedrooms = nil
//                    tempShowVerifiedOnly = false
//                    resetAction()
//                } label: {
//                    Text("Reset")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .foregroundColor(.blue)
//                        .background(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color.blue, lineWidth: 2)
//                        )
//                }
//
//                Button {
//                    applyAction(tempPriceRange, tempSelectedBedrooms, tempShowVerifiedOnly)
//                    withAnimation { isVisible = false }
//                } label: {
//                    Text("Apply Filters")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .foregroundColor(.white)
//                        .background(Color.blue)
//                        .cornerRadius(10)
//                }
//            }
//        }
//        .padding()
//        .background(Color(.systemBackground))
//        .cornerRadius(16)
//        .shadow(radius: 20)
//        .padding()
//    }
//
//    // Bedroom button helper
//    @ViewBuilder
//    private func filterButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
//        Button(action: action) {
//            Text(title)
//                .frame(minWidth: 50)
//                .padding(.vertical, 8)
//                .background(isSelected ? Color.blue : Color(.systemGray5))
//                .foregroundColor(isSelected ? .white : .primary)
//                .cornerRadius(8)
//        }
//    }
//}
//struct FilterCardView: View {
//    @Binding var isVisible: Bool
//
//    // Temporary state for the filters
//    @State private var tempMaxPrice: Double
//    @State private var tempSelectedBedrooms: Int?
//    @State private var tempShowVerifiedOnly: Bool
//
//    // Parent closures
//    var applyAction: (Double, Int?, Bool) -> Void
//    var resetAction: () -> Void
//
//    // Initializer to load parent values into temp
//    init(isVisible: Binding<Bool>,
//         maxPrice: Double,
//         selectedBedrooms: Int?,
//         showVerifiedOnly: Bool,
//         applyAction: @escaping (Double, Int?, Bool) -> Void,
//         resetAction: @escaping () -> Void) {
//
//        _isVisible = isVisible
//        self.applyAction = applyAction
//        self.resetAction = resetAction
//
//        _tempMaxPrice = State(initialValue: maxPrice)
//        _tempSelectedBedrooms = State(initialValue: selectedBedrooms)
//        _tempShowVerifiedOnly = State(initialValue: showVerifiedOnly)
//    }
//
//    var body: some View {
//        VStack(spacing: 20) {
//
//            // HEADER
//            HStack {
//                Text("Filters")
//                    .font(.title2.weight(.bold))
//                Spacer()
//                Button {
//                    withAnimation { isVisible = false }
//                } label: {
//                    Image(systemName: "xmark")
//                        .foregroundColor(.primary)
//                        .padding(8)
//                        .background(Color(.systemGray5))
//                        .clipShape(Circle())
//                }
//            }
//            .padding(.bottom, 10)
//
//            // PRICE SLIDER (ONE SLIDER)
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Max Price")
//                    .font(.headline)
//
//                HStack {
//                    Text("$0")
//                    Spacer()
//                    Text("$\(Int(tempMaxPrice))")
//                }
//
//                Slider(
//                    value: $tempMaxPrice,
//                    in: 600...5000,
//                    step: 50
//                )
//            }
//
//            // BEDROOMS
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Bedrooms")
//                    .font(.headline)
//                HStack {
//                    filterButton(title: "Any", isSelected: tempSelectedBedrooms == nil) {
//                        tempSelectedBedrooms = nil
//                    }
//                    filterButton(title: "1", isSelected: tempSelectedBedrooms == 1) {
//                        tempSelectedBedrooms = 1
//                    }
//                    filterButton(title: "2", isSelected: tempSelectedBedrooms == 2) {
//                        tempSelectedBedrooms = 2
//                    }
//                    filterButton(title: "3+", isSelected: tempSelectedBedrooms == 3) {
//                        tempSelectedBedrooms = 3
//                    }
//                }
//            }
//
//            // VERIFIED TOGGLE
//            Toggle(isOn: $tempShowVerifiedOnly) {
//                Text("Verified Properties Only")
//                    .font(.headline)
//            }
//
//            // ACTION BUTTONS
//            HStack(spacing: 20) {
//
//                // RESET
//                Button {
//                    tempMaxPrice = 5000
//                    tempSelectedBedrooms = nil
//                    tempShowVerifiedOnly = false
//                    resetAction()
//
//                } label: {
//                    Text("Reset")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .foregroundColor(.blue)
//                        .background(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color.blue, lineWidth: 2)
//                        )
//                }
//
//                // APPLY
//                Button {
//                    applyAction(tempMaxPrice, tempSelectedBedrooms, tempShowVerifiedOnly)
//                    withAnimation { isVisible = false }
//
//                } label: {
//                    Text("Apply Filters")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .foregroundColor(.white)
//                        .background(Color.blue)
//                        .cornerRadius(10)
//                }
//            }
//        }
//        .padding()
//        .background(Color(.systemBackground))
//        .cornerRadius(16)
//        .shadow(radius: 20)
//        .padding()
//    }
//
//    // Bedroom button helper
//    @ViewBuilder
//    private func filterButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
//        Button(action: action) {
//            Text(title)
//                .frame(minWidth: 50)
//                .padding(.vertical, 8)
//                .background(isSelected ? Color.blue : Color(.systemGray5))
//                .foregroundColor(isSelected ? .white : .primary)
//                .cornerRadius(8)
//        }
//    }
//}

//
import SwiftUI

struct FilterCardView: View {
    @Binding var isVisible: Bool

    // Temporary state for the filters
    @State private var tempMaxPrice: Double
    @State private var tempSelectedBedrooms: Int?
    @State private var tempShowVerifiedOnly: Bool
    
    // 1. Amenity State Variables
    @State private var tempHasWifi: Bool
    @State private var tempHasParking: Bool
    @State private var tempIsPetFriendly: Bool
    @State private var tempHasGym: Bool

    // Parent closures
    // 2. Updated applyAction signature to include the new Booleans
    var applyAction: (Double, Int?, Bool, Bool, Bool, Bool, Bool) -> Void
    var resetAction: () -> Void
    var onLocationClick: () -> Void

    // Initializer to load parent values into temp
    init(isVisible: Binding<Bool>,
         maxPrice: Double,
         selectedBedrooms: Int?,
         showVerifiedOnly: Bool,
         // 3. Initializer now accepts the new amenity states
         hasWifi: Bool,
         hasParking: Bool,
         isPetFriendly: Bool,
         hasGym: Bool,
         // 4. Updated applyAction type
         applyAction: @escaping (Double, Int?, Bool, Bool, Bool, Bool, Bool) -> Void,
         resetAction: @escaping () -> Void,
    onLocationClick: @escaping () -> Void  ){

        _isVisible = isVisible
        self.applyAction = applyAction
        self.resetAction = resetAction
        self.onLocationClick = onLocationClick

        _tempMaxPrice = State(initialValue: maxPrice)
        _tempSelectedBedrooms = State(initialValue: selectedBedrooms)
        _tempShowVerifiedOnly = State(initialValue: showVerifiedOnly)
        
        // 5. Initialize the new temporary states
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
                    .font(.title2.weight(.bold))
                Spacer()
                Button {
                    withAnimation { isVisible = false }
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
            }
            .padding(.bottom, 10)

            // --- Price Slider ---
            VStack(alignment: .leading, spacing: 8) {
                Text("Max Price")
                    .font(.headline)

                HStack {
                    Text("$0")
                    Spacer()
                    Text("$\(Int(tempMaxPrice))")
                }

                Slider(
                    value: $tempMaxPrice,
                    in: 600...5000,
                    step: 50
                )
            }
            Divider()
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
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(12)
            }
            .padding(.horizontal)

            Divider()

            // --- Bedrooms ---
            VStack(alignment: .leading, spacing: 8) {
                Text("Bedrooms")
                    .font(.headline)
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
            
            // --- Amenities (New Button-Style Filters) ---
            VStack(alignment: .leading, spacing: 8) {
                Text("Amenities")
                    .font(.headline)
                
                // Use a single line for the HStacks for cleaner layout
                HStack {
                    // Wi-Fi
                    amenityButton(title: "Wi-Fi", icon: "wifi", isSelected: tempHasWifi) {
                        tempHasWifi.toggle()
                    }
                    
                    // Parking
                    amenityButton(title: "Parking", icon: "car.fill", isSelected: tempHasParking) {
                        tempHasParking.toggle()
                    }
                }
                
                HStack {
                    // Pet-Friendly
                    amenityButton(title: "Pet-Friendly", icon: "pawprint.fill", isSelected: tempIsPetFriendly) {
                        tempIsPetFriendly.toggle()
                    }
                    
                    // Gym
                    amenityButton(title: "Gym", icon: "figure.strengthtraining.traditional", isSelected: tempHasGym) {
                        tempHasGym.toggle()
                    }
                    Spacer() // Pushes the buttons to the left
                }
            }
            // ---------------------------------------------
            
            Divider()

            // VERIFIED TOGGLE
            Toggle(isOn: $tempShowVerifiedOnly) {
                Text("Verified Properties Only")
                    .font(.headline)
            }

            // ACTION BUTTONS
            HStack(spacing: 20) {

                // RESET
                Button {
                    tempMaxPrice = 5000
                    tempSelectedBedrooms = nil
                    tempShowVerifiedOnly = false
                    
                    // Reset new amenity states
                    tempHasWifi = false
                    tempHasParking = false
                    tempIsPetFriendly = false
                    tempHasGym = false
                    
                    resetAction()
                    withAnimation { isVisible = false }

                } label: {
                    Text("Reset")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.blue)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                }

                // APPLY
                Button {
                    // Pass all filter values to the parent view
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
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 20)
        .padding()
    }

    // Bedroom button helper (Used for Bed count)
    @ViewBuilder
    private func filterButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .frame(minWidth: 50)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
    }
    
    // 🆕 Amenity button helper (New for the amenities)
    @ViewBuilder
    private func amenityButton(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                Text(title)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20) // Use a higher corner radius for a pill-style button
        }
    }
}
