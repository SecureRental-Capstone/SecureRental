//
//  ResetPasswordView.swift
//  SecureRental
//
//  Created by Shehnazdeep Kaur on 2025-11-23.
//


import SwiftUI
import FirebaseAuth

struct ResetPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var email: String = ""
    @State private var message: String = ""
    @State private var isError: Bool = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            
                // Close button
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.gray)
                    .padding()
            }
            
            VStack(spacing: 24) {
                Spacer().frame(height: 20)  // spacing below the X button
                
                Text("Reset Password")
                    .font(.largeTitle)
                    .bold()
                
                Text("Enter your email and we’ll send you a link to reset your password.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                Button(action: resetPassword) {
                    Text("Send Reset Link")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.primaryPurple)
                        .cornerRadius(10)
                }
                
                if !message.isEmpty {
                    Text(message)
                        .foregroundColor(isError ? .red : .green)
                        .padding(.top)
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    func resetPassword() {
        guard !email.isEmpty else {
            message = "Please enter your email."
            isError = true
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                message = error.localizedDescription
                isError = true
            } else {
                message = "A password reset email has been sent."
                isError = false
            }
        }
    }
}

