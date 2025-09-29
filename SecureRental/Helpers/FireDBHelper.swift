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
    
//    // Start or fetch a conversation
//    func startConversation(listingId: String, landlordId: String, tenantId: String) async throws -> String {
//        // Check if conversation exists
//        let query = try await db.collection("conversations")
//            .whereField("participants", arrayContains: tenantId)
//            .getDocuments()
//
//        if let existing = query.documents.first(where: { ($0.data()["participants"] as? [String])?.contains(landlordId) == true }) {
//            return existing.documentID
//        }
//
//        // Create new conversation
//        let conversationRef = db.collection("conversations").document()
//        try await conversationRef.setData([
//            "participants": [tenantId, landlordId],
//            "listingId": listingId,
//            "createdAt": FieldValue.serverTimestamp()
//        ])
//
//        // Auto message
//        try await conversationRef.collection("messages").addDocument(data: [
//            "senderId": tenantId,
//            "text": "Hi, is this listing still available?",
//            "timestamp": FieldValue.serverTimestamp()
//        ])
//
//        return conversationRef.documentID
//    }
    
    func startConversation(listingId: String, landlordId: String, tenantId: String) async throws -> String {
        // Check if conversation exists for THIS listing
//        let query = try await db.collection("conversations")
//            .whereField("participants", arrayContains: tenantId)
//            .whereField("listingId", isEqualTo: listingId)
//            .getDocuments()
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

}
