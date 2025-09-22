//
//  RoleSelectionView.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-09-22.
//

import SwiftUI

struct RoleSelectionView: View {
    @ObservedObject var user: User               // Pass the current User
    var onComplete: () -> Void                   // Closure to call after selection
    @EnvironmentObject var authenticationService: AuthenticationService

    var body: some View {
        VStack(spacing: 30) {
            Text("Select Your Role")
                .font(.largeTitle)
                .bold()

            Button("Tenant") {
                setRole(.tenant)
            }
            .buttonStyle(.borderedProminent)

            Button("Landlord") {
                setRole(.landlord)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    // Set Role
    private func setRole(_ role: UserRole) {
        Task {
            do {
                try await authenticationService.updateRoleInCognito(role: role)
                user.role = role
                onComplete()
            } catch {
                print("Failed to set role: \(error)")
            }
        }
    }
}
