////
////  VerificationView.swift
////  SecureRental
////
////  Created by Haniya Akhtar on 2025-10-04.

import SwiftUI
import Persona2

// MARK: - Main View
struct VerificationView: View {
    // Placeholder state for managing the action (e.g., navigating to verification flow)
    @State private var shouldVerify = false
    @Binding var rootView: RootView
    @State private var errorMessage: String?
    @EnvironmentObject var dbHelper : FireDBHelper
    @State private var isLoading = false
    @State private var showError = false
    private let personaDelegate = PersonaHandler()
        
    var body: some View {
        // 1. Background Layer
        ZStack {
            Color.lightGrayBackground.ignoresSafeArea()

            // 2. Main Card Container (VStack for vertical layout)
            VStack(spacing: 0) {
                // Header Section
                VStack(spacing: 16) {
                    // Success Checkmark Icon with Circular Badge
                    ZStack {
                        // 1. Background Circle (Light green fill)
                        Circle()
                            .fill(Color.lightSuccessBackground)
                            .frame(width: 64, height: 64)

                        // 3. The Checkmark Icon
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 32, weight: .bold)) // Adjust size and weight for visibility
                            .foregroundColor(.primaryPurple)
                    }
                    .padding(.bottom, 8) // Replaces the padding from the old icon

                    // Titles
                    Text("Account Created!")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)

                    Text("Verify Your Identity")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom, 8)
                }
                .padding(.top, 32)
                .padding(.bottom, 40)


                // Feature List Section
                VStack(alignment: .leading, spacing: 20) {
                    FeatureRow(
                        iconName: "checkmark.seal.fill",
                        iconColor: .accentBlue,
                        text: "Verify to submit listings"
                    )

                    FeatureRow(
                        iconName: "shield.lefthalf.filled", // A suitable shield icon from SF Symbols
                        iconColor: .accentBlue,
                        text: "Verify to build trust"
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)

                // Time Estimate
                Text("Takes only 2-3 minutes")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                    .padding(.bottom, 24)

                // Buttons
                VStack(spacing: 12) {
                    // Primary Button: Verify Now
                    Button(action: {
//                        startPersonaFlow()
//                        try await Task.sleep(nanoseconds: 9_000_000_000)
//                        rootView = .main
                        Task {
                            startPersonaFlow()
                            do {
                                try await Task.sleep(nanoseconds: 9_000_000_000)
                                
                                // Ensure UI updates (like changing rootView) run on the MainActor
                                await MainActor.run {
                                    rootView = .main
                                }
                            } catch {
                                print("Task sleep interrupted or failed: \(error)")
                            }
                        }
                    }) {
                        Text("Verify Now")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.primaryPurple)
                            .cornerRadius(12)
                    }

                    // Secondary Button: Skip for Now
                    Button(action: {
                        print("Skip for Now Tapped")
                        rootView = .main
                    }) {
                        Text("Skip for Now")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white)
//                            .overlay( // Creates the subtle border/outline
//                                RoundedRectangle(cornerRadius: 12)
//                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                          //  )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .frame(maxWidth: 400) // Constraints the card width for a better appearance on large screens
            .background(Color.white)
            .cornerRadius(20) // Rounded card corners
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5) // Subtle card shadow
            .padding(20)
        }.onAppear {
            personaDelegate.dbHelper = dbHelper
        }
    }
    
    func startPersonaFlow() {
        isLoading = true
        
        // 1. Define the action to take upon completion, cancellation, or external dismissal.
        // The explicit capture list is now omitted or simply [self] (which is the default).
        let dismissalAction = {
            // Use 'self' directly
            
            // Ensure the dismissal action is run on the main thread for UI updates
            DispatchQueue.main.async {
                // Find and dismiss the presented view controller (the wrapper VC)
                if let wrapperVC = UIApplication.shared.topViewController(of: PersonaWrapperVC.self) {
                    wrapperVC.dismiss(animated: true) {
                        // This block executes *after* the Persona flow is dismissed.
                        self.rootView = .main // Use 'self' directly
                    }
                } else {
                    // Fallback for immediate state change
                    self.rootView = .main // Use 'self' directly
                }
            }
        }

        // Assign the action to the PersonaHandler
        self.personaDelegate.onFlowDismissed = dismissalAction

        createPersonaInquiry(firstName: "Jane", lastName: "Doe", birthdate: "1994-04-12") { result in
            DispatchQueue.main.async {
                isLoading = false

                switch result {
                case .success(let inquiryId):
                    if let topVC = UIApplication.shared.topViewController() {
                        let wrapper = PersonaWrapperVC()
                        wrapper.modalPresentationStyle = .fullScreen
                        wrapper.modalTransitionStyle = .coverVertical

                        // 2. Assign the dismissal action to the wrapper VC
                        wrapper.onDismiss = dismissalAction

                        topVC.present(wrapper, animated: true) {
                            Persona2.Inquiry
                                .from(inquiryId: inquiryId, delegate: self.personaDelegate)
                                .build()
                                .start(from: wrapper)
                        }
                    }

                case .failure(let error):
                    showError = true
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
}
