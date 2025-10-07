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
    
    
//    // MARK: - Insert User
//    func insertUser(user: AppUser) async {
//        do {
//            let data: [String: Any] = [
//                "id": user.id,
//                "username": user.username,
//                "email": user.email,
//                "name": user.name,
//                "profilePictureURL": user.profilePictureURL ?? "",
//                "rating": user.rating,
//                "reviews": user.reviews
//            ]
//            
//            try await db.collection(COLLECTION_USERS).document(user.id).setData(data)
//            print("✅ User inserted successfully")
//            
//            // Update current user
//            self.currentUser = user
//            
//        } catch {
//            print("❌ Failed to insert user: \(error.localizedDescription)")
//        }
//    }
    
    // Retreive User by Id
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
                    rating: data["rating"] as? Double ?? 0.0,
                    reviews: data["reviews"] as? [String] ?? [],
                    favoriteListingIDs: data["favoriteListingIDs"] as? [String] ?? []
                )
//                self.currentUser = user
                return user
            }
        } catch {
            print("❌ Failed to fetch user: \(error.localizedDescription)")
        }
        return nil
    }
    
    // Retrieve User by email
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
                    rating: data["rating"] as? Double ?? 0.0,
                    reviews: data["reviews"] as? [String] ?? [],
                    favoriteListingIDs: data["favoriteListingIDs"] as? [String] ?? [] 
                )
//                self.currentUser = user
                return user
            }
        } catch {
            print("❌ Failed to fetch user by email: \(error.localizedDescription)")
        }
        return nil
    }
    
    // Update user
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

  
    func addListing(_ listing: Listing, images: [UIImage]) async throws {
        var mutableListing = listing
        var uploadedURLs: [String] = []

        for image in images {
            let url = try await CloudinaryHelper.uploadImage(image)
            uploadedURLs.append(url)
        }

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
    
    func startConversation(listingId: String, landlordId: String, tenantId: String) async throws -> String {
        let currentUserId = Auth.auth().currentUser?.uid ?? ""
        let query = try await db.collection("conversations")
            .whereField("participants", arrayContains: currentUserId)
            .whereField("listingId", isEqualTo: listingId)
            .getDocuments()
        if let existing = query.documents.first {
            return existing.documentID
        }

        // Create new conversation
        let conversationRef = db.collection("conversations").document()
        try await conversationRef.setData([
            "participants": [tenantId, landlordId],
            "listingId": listingId,
            "createdAt": FieldValue.serverTimestamp()
        ])

        // Auto message
        try await conversationRef.collection("messages").addDocument(data: [
            "senderId": tenantId,
            "text": "Hi, is this listing still available?",
            "timestamp": FieldValue.serverTimestamp()
        ])

        return conversationRef.documentID
    }
    
    func fetchListing(byId id: String) async throws -> Listing? {
        let doc = try await db.collection("Listings").document(id).getDocument()
        return try doc.data(as: Listing.self)
    }



    // Send message
    func sendMessage(conversationId: String, senderId: String, text: String) async throws {
        try await db.collection("conversations")
            .document(conversationId)
            .collection("messages")
            .addDocument(data: [
                "senderId": senderId,
                "text": text,
                "timestamp": FieldValue.serverTimestamp()
            ])
    }

    // Listen for messages
    func listenForMessages(conversationId: String, completion: @escaping ([ChatMessage]) -> Void) -> ListenerRegistration {
        return db.collection("conversations")
            .document(conversationId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                let messages = documents.compactMap { doc -> ChatMessage? in
                    try? doc.data(as: ChatMessage.self)
                }
                completion(messages)
            }
    }
    
    
        // Delete a listing from Firestore and its associated images
    func deleteListing(_ listing: Listing) async throws {
            
        try await db.collection(COLLECTION_LISTINGS).document(listing.id).delete()
        print("✅ Listing \(listing.id) deleted from Firestore")
        
        
    }
    
    // MARK: - Fetch Last Message for Conversation
    func fetchLastMessage(for conversationId: String) async throws -> ChatMessage? {
        let snapshot = try await db.collection("conversations")
            .document(conversationId)
            .collection("messages")
            .order(by: "timestamp", descending: true)
            .limit(to: 1)
            .getDocuments()

        if let doc = snapshot.documents.first {
            return try doc.data(as: ChatMessage.self)
        } else {
            return nil
        }
    }

    
    func toggleFavorite(listingId: String) async throws {
        guard let user = currentUser else { return }
        var updatedFavorites = user.favoriteListingIDs

        if let index = updatedFavorites.firstIndex(of: listingId) {
            updatedFavorites.remove(at: index) // remove
        } else {
            updatedFavorites.append(listingId) // add
        }

        // Update Firestore
        try await db.collection(COLLECTION_USERS)
            .document(user.id)
            .updateData(["favoriteListingIDs": updatedFavorites])

        // Update local user
        currentUser?.favoriteListingIDs = updatedFavorites
    }
    
    func addReview(to listing: Listing, rating: Double, comment: String, user: AppUser) {
        let reviewsRef = db.collection("Listings").document(listing.id).collection("reviews")
        let reviewRef = reviewsRef.document() // Auto-generated ID
        
        let reviewData: [String: Any] = [
            "userId": user.id,
            "userName": user.name,
            "rating": rating,
            "comment": comment,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
            // Add the review
        reviewRef.setData(reviewData) { error in
            if let error = error {
                print("❌ Failed to add review: \(error.localizedDescription)")
                return
            }
            print("✅ Review added successfully")
            
                // Update average
            self.updateAverageRating(for: listing, newRating: rating)
        }
    }
    
//    private func updateAverageRating(for listing: Listing, newRating: Double) {
//        let listingRef = db.collection("Listings").document(listing.id)
//        
//        listingRef.getDocument { snapshot, error in
//            guard let data = snapshot?.data(), error == nil else {
//                print("❌ Failed to fetch listing for average rating")
//                return
//            }
//            
//            let currentAverage = data["averageRating"] as? Double ?? 0.0
//            let ratingsCount = data["ratingsCount"] as? Int ?? 0
//            
//            var updatedAverage: Double
//            var updatedCount: Int
//            
//            if ratingsCount == 0 {
//                    // First rating
//                updatedAverage = newRating
//                updatedCount = 1
//            } else {
//                    // Compute new average
//                updatedCount = ratingsCount + 1
//                updatedAverage = (currentAverage * Double(ratingsCount) + newRating) / Double(updatedCount)
//            }
//            
//             
//            let roundedAverage = Double(round(100 * updatedAverage) / 100)
//            
//            listingRef.updateData([
//                "averageRating": roundedAverage,
//                "ratingsCount": updatedCount
//            ]) { error in
//                if let error = error {
//                    print("❌ Failed to update average rating: \(error.localizedDescription)")
//                } else {
//                    print("✅ Average rating updated: \(updatedAverage)")
//                }
//            }
//        }
//    }
    private func updateAverageRating(for listing: Listing, newRating: Double) {
        let listingRef = db.collection("Listings").document(listing.id)
        
        listingRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                print("❌ Failed to fetch listing for average rating")
                return
            }
            
            let currentAverage = data["averageRating"] as? Double ?? 0.0
            let ratingsCount = data["ratingsCount"] as? Int ?? 0
            let ownerId = data["landlordId"] as? String ?? ""
            
            var updatedAverage: Double
            var updatedCount: Int
            
            if ratingsCount == 0 {
                    // First rating
                updatedAverage = newRating
                updatedCount = 1
            } else {
                    // Compute new average
                updatedCount = ratingsCount + 1
                updatedAverage = (currentAverage * Double(ratingsCount) + newRating) / Double(updatedCount)
            }
            
                // Round to 2 decimals
            let roundedAverage = Double(round(100 * updatedAverage) / 100)
            
                // Update Listing
            listingRef.updateData([
                "averageRating": roundedAverage,
                "ratingsCount": updatedCount
            ]) { error in
                if let error = error {
                    print("❌ Failed to update average rating: \(error.localizedDescription)")
                } else {
                    print("✅ Average rating updated for listing: \(roundedAverage)")
                    
                        // ✅ Update the owner's rating
                    self.updateUserRating(for: ownerId)
                }
            }
        }
    }
    
        // MARK: - Update the landlord's rating based on all their listings
//    private func updateUserRating(for ownerId: String) {
//        let listingsRef = db.collection("Listings").whereField("landlordId", isEqualTo: ownerId)
//        
//        listingsRef.getDocuments { snapshot, error in
//            guard let docs = snapshot?.documents, error == nil, !docs.isEmpty else { return }
//            
//            let total = docs.reduce(0.0) { sum, doc in
//                sum + (doc.data()["averageRating"] as? Double ?? 0.0)
//            }
//            
//            let userAverage = total / Double(docs.count)
//            let rounded = Double(round(100 * userAverage) / 100)
//            
//            self.db.collection("Users").document(ownerId).updateData([
//                "rating": rounded
//            ]) { error in
//                if let error = error {
//                    print("❌ Failed to update user rating: \(error.localizedDescription)")
//                } else {
//                    print("✅ User rating updated: \(rounded)")
//                }
//            }
//        }
//    }



    private func updateUserRating(for ownerId: String) {
        guard Auth.auth().currentUser != nil else {
            print("❌ No authenticated user. Can't update user rating.")
            return
        }
        
        let listingsRef = db.collection("Listings").whereField("landlordId", isEqualTo: ownerId)
        
        listingsRef.getDocuments { snapshot, error in
            if let error = error {
                print("❌ Failed to fetch listings: \(error.localizedDescription)")
                return
            }
            guard let docs = snapshot?.documents, !docs.isEmpty else {
                print("❌ No listings found for this landlord")
                return
            }
            
            let total = docs.reduce(0.0) { sum, doc in
                let rating = doc.data()["averageRating"] as? Double ?? 0.0
                return sum + rating
            }
            
            let userAverage = total / Double(docs.count)
            let rounded = Double(round(100 * userAverage) / 100)
            
            DispatchQueue.main.async {
                self.db.collection("Users").document(ownerId).updateData([
                    "rating": rounded
                ]) { error in
                    if let error = error {
                        print("❌ Failed to update user rating: \(error.localizedDescription)")
                    } else {
                        print("✅ User rating updated: \(rounded)")
                    }
                }
            }
        }
    }




}
