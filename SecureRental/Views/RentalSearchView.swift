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
    }
}
//                        SearchBar(text: $viewModel.searchText)
//                            .padding(.horizontal)
//import SwiftUI
//
//struct SearchBar: UIViewRepresentable {
//    @Binding var text: String
//
//    class Coordinator: NSObject, UISearchBarDelegate {
//        @Binding var text: String
//
//        init(text: Binding<String>) {
//            _text = text
//        }
//
//        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//            text = searchText
//        }
//
//        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//            searchBar.resignFirstResponder()
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(text: $text)
//    }
//
//    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
//        let searchBar = UISearchBar(frame: .zero)
//        searchBar.delegate = context.coordinator
//        searchBar.placeholder = "Search Listings"
//        return searchBar
//    }
//
//    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
//        uiView.text = text
//    }
//}
//
//struct SearchBar_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchBar(text: .constant(""))
//    }
//}
