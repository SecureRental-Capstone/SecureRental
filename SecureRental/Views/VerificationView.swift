//
//  VerificationView.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2025-10-04.
//

import SwiftUI
import Persona2

struct VerificationView: View {
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showChatbot = false

    
    private let personaDelegate = PersonaHandler()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Verify Your Identity")
                .font(.title)

            Button(action: {
                startPersonaFlow()
            }) {
                Text("Start Verification")
            }
            
            Text("Chatbot")
                .font(.title)

            Button("Open Chatbot") {
                showChatbot = true
            }
            .sheet(isPresented: $showChatbot) {
                ChatbotView()
            }
            
            
            if isLoading {
                ProgressView()
            }
        }
        .padding()
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    func startPersonaFlow() {
        isLoading = true

        createPersonaInquiry(firstName: "Jane", lastName: "Doe", birthdate: "1994-04-12") { result in
            DispatchQueue.main.async {
                isLoading = false

                switch result {
                case .success(let inquiryId):
                    print("Inquiry ID: \(inquiryId)")

                    // Launch the Persona SDK flow using the delegate handler
                    if let topVC = UIApplication.shared.topViewController() {
                        Persona2.Inquiry
                            .from(inquiryId: inquiryId, delegate: personaDelegate)  // Pass your delegate here
                            .build()
                            .start(from: topVC)
                    }

                case .failure(let error):
                    showError = true
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

