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
        
    }
    
        //    private func login() async {
        //        // Insert user
        ////        let newUser = AppUser(username: "john123", email: "john@example.com", name: "John Doe")
        //
        //        // Fetch user by UID
        //        if let user = await dbHelper.getUser(byEmail: email) {
        //            print(user.email)
        //        }
        //    }
    private func login() async {
        guard !email.isEmpty, !password.isEmpty else {
            //errorMessage = "Please enter email and password."
            showAlert = true
            return
        }
        do {
            try await dbHelper.signIn(email: email, password: password)
            rootView = .main
        } catch {
            //errorMessage = error.localizedDescription
            showAlert = true
        }
    }

    }
