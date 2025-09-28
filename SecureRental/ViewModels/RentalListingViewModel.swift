//
//  RentalListingViewModel.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2024-11-07.
//

//
//  RentalListingViewModel.swift
//  SecureRental
//
//  Created by Anchal Sharma on 2024-11-07.
//

import Foundation
import Combine
import UIKit
import SwiftUICore
import FirebaseAuth

@MainActor
class RentalListingsViewModel: ObservableObject {
    @Published var listings: [Listing] = []
    private let dbHelper = FireDBHelper.getInstance()
//    private lazy var dbHelper: FireDBHelper = {
//            FireDBHelper.getInstance()
//        }()
//    @EnvironmentObject var dbHelper : FireDBHelper

    @Published var searchText: String = ""
    @Published var selectedAmenities: [String] = []
    @Published private(set) var favoriteListingIDs: Set<String> = []

    
        // Derived property for favorite listings
    var favouriteListings: [Listing] {
        listings.filter { favoriteListingIDs.contains($0.id) }
    }

    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Fetch initial data from backend or local storage
        fetchListings()
        
        // Setup search functionality combining search text and selected amenities
        Publishers.CombineLatest($searchText, $selectedAmenities)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates { (prev, current) in
                prev.0 == current.0 && prev.1 == current.1
            }
            .sink { [weak self] (searchTerm, amenities) in
                self?.filterListings(searchTerm: searchTerm, amenities: amenities)
            }
            .store(in: &cancellables)
    }
    
    func fetchListings() {
        Task {
            do {
                let fetched = try await dbHelper.fetchListings()
                await MainActor.run {
                    self.listings = fetched
                }
            } catch {
                print("❌ Failed to fetch listings: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchMyListings() {
        Task {
            do {
                let fetched = try await dbHelper.fetchListingsForCurrentUser()
                await MainActor.run {
                    self.listings = fetched
                }
            } catch {
                print("❌ Failed to fetch my listings: \(error.localizedDescription)")
            }
        }
    }
//    // Fetches rental listings from the backend or local storage.
//    func fetchListings() {
//        let sampleImage = UIImage(named: "sampleImage") ?? UIImage()  // Provide a default image if nil
//        // Placeholder data; replace with actual backend fetching logic
//        listings = [
//            Listing(
//                id: "Cozy Apartment",
//                title: "A charming one-bedroom apartment in the heart of downtown.",
//                description: "1200",
//                price: "1",
//                imageURLs: ["Toronto"],
//                location: "Toronto",
//                isAvailable: true,
//                numberOfBedrooms: 1,
//                numberOfBathrooms: 1,
//                squareFootage: 600,
//                amenities: ["WiFi", "Washer/Dryer", "Pet-friendly"],
//                street: "123 Main St",
//                city: "Toronto",
//                province: "ON",
//                comments: ["123"],
//                datePosted: Date(),
//                landlordId: "1"
//            ),
//            Listing(
//                id: "Luxury Condo",
//                title: "Spacious 2-bedroom, 2-bathroom condo with amazing city views.",
//                description: "2500",
//                price: "1",
//                imageURLs: ["Toronto"],
//                location: "Toronto",
//                isAvailable: false,
//                numberOfBedrooms: 2,
//                numberOfBathrooms: 2,
//                squareFootage: 1100,
//                amenities: ["Gym", "Parking", "Swimming Pool"],
//                street: "456 Elm St",
//                city: "Toronto",
//                province: "ON",
//                comments: ["123"],
//                datePosted: Date(),
//                landlordId: "2"
//            )
//        ]
//    }
    
//    // Adds a new rental listing.
//    // - Parameter listing: The `RentalListing` to add.
//    func addListing(_ listing: Listing) {
//        listings.append(listing)
//        // TODO: Add backend call to save the listing
//    }
    
    func addListing(_ listing: Listing, images: [UIImage]) {
        Task {
            do {
                try await dbHelper.addListing(listing, images: images)
                await fetchListings() // refresh after save
            } catch {
                print("❌ Failed to add listing: \(error.localizedDescription)")
            }
        }
    }
// Listen for ALL listings
//   func listenToAllListings(completion: @escaping ([Listing]) -> Void) {
//       let listener = db.collection("Listings")
//           .order(by: "datePosted", descending: true)
//           .addSnapshotListener { snapshot, error in
//               guard let docs = snapshot?.documents else {
//                   print("❌ Failed to listen: \(error?.localizedDescription ?? "Unknown error")")
//                   return
//               }
//               let listings = docs.compactMap { try? $0.data(as: Listing.self) }
//               completion(listings)
//           }
//       FireDBHelper.listeners.append(listener)
//   }
   
//   // Listen for listings of current user
//   func listenToMyListings(completion: @escaping ([Listing]) -> Void) {
//       guard let uid = Auth.auth().currentUser?.uid else { return }
//       
//       let listener = db.collection("Listings")
//           .whereField("landlordId", isEqualTo: uid)
//           .order(by: "datePosted", descending: true)
//           .addSnapshotListener { snapshot, error in
//               guard let docs = snapshot?.documents else {
//                   print("❌ Failed to listen my listings: \(error?.localizedDescription ?? "Unknown error")")
//                   return
//               }
//               let listings = docs.compactMap { try? $0.data(as: Listing.self) }
//               completion(listings)
//           }
//       FireDBHelper.listeners.append(listener)
//   }
//   
//   // Stop all listeners (call on logout for cleanup)
//   func detachListeners() {
//       FireDBHelper.listeners.forEach { $0.remove() }
//       FireDBHelper.listeners.removeAll()
//   }
    // Updates an existing rental listing.
    // - Parameter listing: The `RentalListing` with updated information.
    func updateListing(_ listing: Listing) {
        if let index = listings.firstIndex(where: { $0.id == listing.id }) {
            listings[index] = listing
            // TODO: Add backend call to update the listing
        }
    }
    
    // Filters listings based on search text and selected amenities.
    // - Parameters:
    //   - searchTerm: The text input by the user for searching.
    //   - amenities: The list of amenities selected by the user for filtering.
    private func filterListings(searchTerm: String, amenities: [String]) {
        if searchTerm.isEmpty && amenities.isEmpty {
            fetchListings()
        } else {
            listings = listings.filter { listing in
                let matchesSearch = searchTerm.isEmpty ||
                    listing.title.lowercased().contains(searchTerm.lowercased()) ||
                    listing.description.lowercased().contains(searchTerm.lowercased())
                
                let matchesAmenities = amenities.isEmpty ||
                    amenities.allSatisfy { listing.amenities.contains($0) }
                
                return matchesSearch && matchesAmenities
            }
        }
    }
    
    func toggleFavorite(for listing: Listing) {
        if favoriteListingIDs.contains(listing.id) {
            favoriteListingIDs.remove(listing.id)
        } else {
            favoriteListingIDs.insert(listing.id)
        }
    }
    
    func isFavorite(_ listing: Listing) -> Bool {
        return favoriteListingIDs.contains(listing.id)
    }
}

     // Add a rating or comment to a listing
//     func addComment(to listing: RentalListing, comment: String) {
//         if let index = listings.firstIndex(where: { $0.id == listing.id }) {
//             listings[index].comments.append(comment)
//         }
//     }
//
//     func addRating(to listing: RentalListing, rating: Int) {
//         if let index = listings.firstIndex(where: { $0.id == listing.id }) {
//             listings[index].ratings.append(rating)
//         }
//     }


