//
//  FireDBHelper.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-09-23.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class FireDBHelper: ObservableObject {
    
    @Published var currentUser: AppUser?
    
    private var db = Firestore.firestore()
    private static var shared: FireDBHelper?
    
    private let COLLECTION_USERS = "Users"
    
    private init() {}
    
    static func getInstance() -> FireDBHelper {
        if shared == nil {
            shared = FireDBHelper()
        }
        return shared!
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
}
