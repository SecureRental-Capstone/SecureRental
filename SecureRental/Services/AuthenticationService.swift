//
//  AuthenticationService.swift
//  SecureRental
//
//  Created by Shehnazdeep Kaur on 2024-12-06.
//

import Amplify
import AuthenticationServices
import AWSCognitoAuthPlugin
import SwiftUI

@MainActor
class AuthenticationService: ObservableObject {
    @Published var isSignedIn = false
    
    func fetchSession() async {
        do {
            let result = try await Amplify.Auth.fetchAuthSession()
            isSignedIn = result.isSignedIn
            print("Fetch session completed. isSignedIn = \(isSignedIn)")
        } catch {
            print("Fetch Session failed with error: \(error)")
        }
    }
    
    func signIn(presentationAnchor: ASPresentationAnchor) async {
        do {
            let result = try await Amplify.Auth.signInWithWebUI(
                presentationAnchor: presentationAnchor,
                options: .preferPrivateSession()
            )
            isSignedIn = result.isSignedIn
            print("Sign In completed. isSignedIn = \(isSignedIn)")
        } catch {
            print("Sign In failed with error: \(error)")
        }
    }
    
    func signOut() async {
        guard let result = await Amplify.Auth.signOut() as? AWSCognitoSignOutResult else {
            return
        }
        switch result {
        case .complete, .partial:
            isSignedIn = false
        case .failed:
            break
        }
        print("Sign Out completed. isSignedIn = \(isSignedIn)")
    }
    
    func getCurrentUserId() async -> String? {
        do {
            let user = try await Amplify.Auth.getCurrentUser()
            return user.userId
        } catch {
            print("Failed to get userId: \(error)")
            return nil
        }
    }
    
    func updateRoleInCognito(role: UserRole) async throws {
        let user = try await Amplify.Auth.getCurrentUser()
            
        let attributes = [AuthUserAttribute(.custom("role"), value: role.rawValue)]
        try await Amplify.Auth.update(userAttributes: attributes)
        
        print("Role saved in Cognito: \(role.rawValue)")
    }
    
    func fetchRole() async throws -> UserRole? {
        let attributes = try await Amplify.Auth.fetchUserAttributes()
        if let roleAttr = attributes.first(where: { $0.key.rawValue == "custom:role" }) {
            return UserRole(rawValue: roleAttr.value)
        }
        return nil
    }

}
