//
//  FireDBHelper.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-09-23.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import UIKit

@MainActor
class FireDBHelper: ObservableObject {
    
    @Published var currentUser: AppUser?
    
    private var db = Firestore.firestore()
    private static var shared: FireDBHelper?
    public static var listeners: [ListenerRegistration] = []

    
    private let COLLECTION_USERS = "Users"
    private var COLLECTION_LISTINGS: String { "Listings" }
    
    static let instance = FireDBHelper()
    private init() {}

    
    static func getInstance() -> FireDBHelper {
        if shared == nil {
            shared = FireDBHelper()
        }
        return shared!
    }
    
        // MARK: - Sign Up (Auth + Firestore)
    func signUp(email: String, password: String, name: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let uid = result.user.uid
        let newUser = AppUser(id: uid, username: email, email: email, name: name)
        try await db.collection(COLLECTION_USERS).document(uid).setData([
            "id": uid,
            "username": email,
            "email": email,
            "name": name,
            "profilePictureURL": "",
            "rating": 0,
            "reviews": []
        ])
        self.currentUser = newUser
    }
    
        // MARK: - Sign In (Auth)
    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        let uid = result.user.uid
            // Fetch user profile from Firestore
        if let user = try await getUser(byUID: uid) {
            self.currentUser = user
        }
    }
    
    
    // MARK: - Insert User
    func insertUser(user: AppUser) async {
        do {
            let data: [String: Any] = [
                "id": user.id,
                "username": user.username,
                "email": user.email,
                "name": user.name,
                "profilePictureURL": user.profilePictureURL ?? "",
                "rating": user.rating,
                "reviews": user.reviews
            ]
            
            try await db.collection(COLLECTION_USERS).document(user.id).setData(data)
            print("✅ User inserted successfully")
            
            // Update current user
            self.currentUser = user
            
        } catch {
            print("❌ Failed to insert user: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Retrieve User by UID
    func getUser(byUID uid: String) async -> AppUser? {
        do {
            let doc = try await db.collection(COLLECTION_USERS).document(uid).getDocument()
            if let data = doc.data() {
                let user = AppUser(
                    id: data["id"] as? String ?? "",
                    username: data["username"] as? String ?? "",
                    email: data["email"] as? String ?? "",
                    name: data["name"] as? String ?? "",
                    profilePictureURL: data["profilePictureURL"] as? String,
                    rating: data["rating"] as? Int ?? 0,
                    reviews: data["reviews"] as? [String] ?? []
                )
                self.currentUser = user
                return user
            }
        } catch {
            print("❌ Failed to fetch user: \(error.localizedDescription)")
        }
        return nil
    }
    
    // MARK: - Retrieve User by Email
    func getUser(byEmail email: String) async -> AppUser? {
        do {
            let query = try await db.collection(COLLECTION_USERS)
                .whereField("email", isEqualTo: email)
                .getDocuments()
            
            if let doc = query.documents.first {
                let data = doc.data()
                let user = AppUser(
                    id: data["id"] as? String ?? "",
                    username: data["username"] as? String ?? "",
                    email: data["email"] as? String ?? "",
                    name: data["name"] as? String ?? "",
                    profilePictureURL: data["profilePictureURL"] as? String,
                    rating: data["rating"] as? Int ?? 0,
                    reviews: data["reviews"] as? [String] ?? []
                )
                self.currentUser = user
                return user
            }
        } catch {
            print("❌ Failed to fetch user by email: \(error.localizedDescription)")
        }
        return nil
    }
    
    // MARK: - Update User
    func updateUser(user: AppUser) async {
        do {
            let data: [String: Any] = [
                "username": user.username,
                "email": user.email,
                "name": user.name,
                "profilePictureURL": user.profilePictureURL ?? "",
                "rating": user.rating,
                "reviews": user.reviews
            ]
            
            try await db.collection(COLLECTION_USERS).document(user.id).updateData(data)
            print("✅ User updated successfully")
            self.currentUser = user
            
        } catch {
            print("❌ Failed to update user: \(error.localizedDescription)")
        }
    }
    
//    // Upload one image to Firebase Storage and return URL
//   func uploadImage(_ image: UIImage, listingId: String) async throws -> String {
//       guard let imageData = image.jpegData(compressionQuality: 0.8) else {
//           throw NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image"])
//       }
//       
//       let storageRef = Storage.storage().reference()
//           .child("listingImages/\(listingId)/\(UUID().uuidString).jpg")
//       
//       _ = try await storageRef.putDataAsync(imageData)
//       let downloadURL = try await storageRef.downloadURL()
//       return downloadURL.absoluteString
//   }
//
    func uploadImage(_ image: UIImage, listingId: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Image data is nil for listing \(listingId)")
            throw NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image"])
        }
        
        let fileName = "\(UUID().uuidString).jpg"
        let storageRef = Storage.storage().reference().child("listingImages/\(listingId)/\(fileName)")
        print("📤 Uploading to: listingImages/\(listingId)/\(fileName), size: \(imageData.count) bytes")
        
        _ = try await storageRef.putDataAsync(imageData)
        let downloadURL = try await storageRef.downloadURL()
        print("✅ Uploaded, URL: \(downloadURL.absoluteString)")
        return downloadURL.absoluteString
    }

   // Add a listing with image uploads
   func addListing(_ listing: Listing, images: [UIImage]) async throws {
       var mutableListing = listing
       var uploadedURLs: [String] = []
       
       // Only upload if there are images
//       if !images.isEmpty {
//           for img in images {
//               let url = try await uploadImage(img, listingId: listing.id)
//               uploadedURLs.append(url)
//           }
//       }

       mutableListing.imageURLs = uploadedURLs
       
       let data = try Firestore.Encoder().encode(mutableListing)
       try await db.collection(COLLECTION_LISTINGS).document(mutableListing.id).setData(data)
   }
   
   // Fetch all listings
   func fetchListings() async throws -> [Listing] {
       let snapshot = try await db.collection(COLLECTION_LISTINGS).getDocuments()
       let listings = snapshot.documents.compactMap { doc in
           try? doc.data(as: Listing.self)
       }
       return listings
   }
    
    // Fetch listings only for the current landlord
    func fetchListingsForCurrentUser() async throws -> [Listing] {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
        }
        
        let snapshot = try await db.collection("Listings")
            .whereField("landlordId", isEqualTo: uid)
            .getDocuments()
        
        let listings = snapshot.documents.compactMap { doc in
            try? doc.data(as: Listing.self)
        }
        return listings
    }
    
    func updateListing(_ listing: Listing) async throws {
        let data = try Firestore.Encoder().encode(listing)
        try await db.collection("Listings").document(listing.id).setData(data)
        print("✅ Listing updated in Firestore")
    }
    
}
