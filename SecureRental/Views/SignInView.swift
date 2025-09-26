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
    
    private func login() async {
        // Insert user
//        let newUser = AppUser(username: "john123", email: "john@example.com", name: "John Doe")
        
        // Fetch user by UID
        if let user = await dbHelper.getUser(byEmail: email) {
            print(user.email)
        }
    }
    
//    private func login() {
//        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
//            if let error = error {
//                print("Login failed: \(error.localizedDescription)")
//                return
//            }
//            
//            guard let user = authResult?.user else { return }
//            print("Login successful for: \(user.email ?? "")")
//            
//            // Save to UserDefaults if needed
//            UserDefaults.standard.set(user.email, forKey: "KEY_EMAIL")
//            UserDefaults.standard.set(user.uid, forKey: "KEY_USER_ID")
//            
////            // Fetch profile from Firestore
////            dbHelper.getUser(byUID: user.uid){ appUser in
////                if let appUser = appUser {
////                    dbHelper.currentUser = appUser
////                    print("Loaded AppUser: \(appUser.username)")
////                } else {
////                    print("No profile found in Firestore for uid: \(user.uid)")
////                }
////                
////                // Navigate to main view
////                self.rootView = .main
////            }
//        }
    }
