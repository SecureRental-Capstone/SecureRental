//
//  SignInView.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-09-23.
//

import SwiftUI
import FirebaseAuth

struct SignInView: View {
    
    @Binding var rootView : RootView
    @EnvironmentObject var dbHelper : FireDBHelper
    @State private var email : String = ""
    @State private var password : String = ""
    @State private var errorMessage: String?
    @State private var showAlert: Bool = false
    @State private var showResetPassword = false


    var body: some View {
        // 1. Background Layer
        ZStack {
            Color.lightGrayBackground.ignoresSafeArea()

            // Outer VStack to align the logo, title, and the card vertically
            VStack(spacing: 20) {

                Group {

                        Text("SecureRental")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryPurple)
                }

                VStack(spacing: 0) {
                    // Form Fields Section
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.headline)
                                .foregroundColor(.gray)

                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(.gray)
                                TextField("", text: $email, prompt: Text(verbatim: "account@email.com"))
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)

                            }
                            .modifier(CustomTextFieldStyle())
                        }

                        // Password Field (with Forgot link)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Password")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                Spacer()
                            }
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(.gray)
                                SecureField("••••••••", text: $password)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            .modifier(CustomTextFieldStyle())
                            //}
                            Button(action: {
                                showResetPassword = true
                            }) {
                                Text("Forgot?")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primaryPurple)
                            }
                            
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                    .padding(.bottom, 30) // Increased bottom padding for fields block

                    // Sign In Button
                    Button(action: {
                        Task {
                            await login()
                        }
                    }) {
                        Text("Sign In") // Updated Button Text
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.primaryPurple)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)

                    // Or Divider
                    HStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                        Text("or")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 10)
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)

                    // Don't have an account? Sign up
                    HStack(spacing: 4) {
                        Text("Don't have an account?") // Updated text
                            .font(.body)
                            .foregroundColor(.gray)
                        Button(action: {
                            self.rootView = .signUp
                            // Navigate to sign-up screen
                        }) {
                            Text("Sign up") // Updated text
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.primaryPurple)
                        }
                    }
                    .padding(.bottom, 32)
                }
                .frame(maxWidth: 400)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 20)
            .sheet(isPresented: $showResetPassword) {
                ResetPasswordView()
            }
            .padding()
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Something went wrong")
            }
            
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }

    private func login() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password."
            showAlert = true
            return
        }
        
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address."
            showAlert = true
            return
        }
        
        do {
            try await dbHelper.signIn(email: email, password: password)
            rootView = .main
        } catch {
            errorMessage = error.localizedDescription
            showAlert = true
        }
    }
}
