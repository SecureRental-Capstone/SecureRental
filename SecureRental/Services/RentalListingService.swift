////
////  RentalListingService.swift
////  SecureRental
////
////  Created by Shehnazdeep Kaur on 2024-12-06.
////
//
//import Amplify
//import SwiftUI
//
//@MainActor
//class RentalListingService: ObservableObject {
//    @Published var rentalListings: [RentalListing] = []
//    
//        // Fetch all rental listings
//    func fetchRentalListings() async {
//        do {
//            let result = try await Amplify.API.query(request: .list(RentalListing.self))
//            switch result {
//            case .success(let listings):
//                print("Fetched \(listings.count) rental listings")
//                rentalListings = listings.elements
//            case .failure(let error):
//                print("Fetch Rental Listings failed with error: \(error)")
//            }
//        } catch {
//            print("Fetch Rental Listings failed with error: \(error)")
//        }
//    }
//    
//        // Save a new rental listing
//    func save(_ listing: RentalListing) async {
//        do {
//            let result = try await Amplify.API.mutate(request: .create(listing))
//            switch result {
//            case .success(let listing):
//                print("Save rental listing completed")
//                rentalListings.append(listing)
//            case .failure(let error):
//                print("Save Rental Listing failed with error: \(error)")
//            }
//        } catch {
//            print("Save Rental Listing failed with error: \(error)")
//        }
//    }
//    
//        // Delete an existing rental listing
//    func delete(_ listing: RentalListing) async {
//        do {
//            let result = try await Amplify.API.mutate(request: .delete(listing))
//            switch result {
//            case .success(let listing):
//                print("Delete rental listing completed")
//                rentalListings.removeAll(where: { $0.id == listing.id })
//            case .failure(let error):
//                print("Delete Rental Listing failed with error: \(error)")
//            }
//        } catch {
//            print("Delete Rental Listing failed with error: \(error)")
//        }
//    }
//}
