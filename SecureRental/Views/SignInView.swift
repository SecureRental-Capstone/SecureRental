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
    
    var body: some View {
        VStack {
            Spacer()
            
            Image("Logo") // Replace with your app logo
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 120)
                .padding(.vertical, 32)
            
            Text("SecureRental")
                .font(.title)
            
            TextField("Email address", text: $email)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
            
            SecureField("Password", text: $password)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
            
            Button(action: {
                Task {
                    await login()
                }
                    //                login()
            }) {
                Text("Login")
                    .padding(EdgeInsets(top: 6, leading: 5, bottom: 6, trailing: 5))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.top, 24)
            
            Button(action: {
                self.rootView = .signUp
            }) {
                Text("Don't have an account? Sign Up")
                    .foregroundColor(.blue)
            }
            
            Spacer()
        }
        .padding()
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "Something went wrong")
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
