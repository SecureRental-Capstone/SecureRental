//
//  VerifyIdentityView.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2025-11-30.
import SwiftUI
import Persona2

struct VerifyIdentityCard: View {
    
    @EnvironmentObject var dbHelper: FireDBHelper
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage: String?
    @Binding var rootView: RootView
    
    private let personaDelegate = PersonaHandler()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                // Circle with warning icon
                ZStack {
                    Circle()
                        .fill(Color.primaryPurple)
                        .frame(width: 40, height: 40)
                    Image(systemName: "exclamationmark.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .foregroundColor(.orange)
                }
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Verify Your Identity")
                        .font(.headline)
                        .fontWeight(.none)
                        .foregroundColor(.black)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.seal")
                                .foregroundColor(Color.black)
                            Text("Post listings")
                                .foregroundColor(Color.black)
                                .font(.subheadline)
                        }
                        
                        HStack(spacing: 6) {
                            Image(systemName: "shield")
                                .foregroundColor(Color.black)
                            Text("Build trust with users")
                                .foregroundColor(Color.black)
                                .font(.subheadline)
                        }
                    }
                }
            }.lineSpacing(15)
            
            
            Button(action: { startPersonaFlowFromProfile() })
            {
                Text("Verify Now")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Color.primaryPurple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
        .onAppear { personaDelegate.dbHelper = dbHelper }
    }
    
    func startPersonaFlowFromProfile() {
        isLoading = true
      
        let dismissalAction = {
           
            DispatchQueue.main.async {
                // Find and dismiss the presented view controller (the wrapper VC)
                if let wrapperVC = UIApplication.shared.topViewController(of: PersonaWrapperVC.self) {
                    wrapperVC.dismiss(animated: true) {
                      
                        self.rootView = .main // Use 'self' directly
                    }
                } else {
                   
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
