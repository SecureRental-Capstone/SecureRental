//
//  SignInView.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2024-10-19.
//
//import SwiftUI
//
//struct SignInView: View {
//    
//    @Binding var rootView: RootView
//    @State private var email: String = ""
//    @State private var password: String = ""
//    
//    //init DynamoDBService with the region and table name
//   // private var dynamoDBService: DynamoDBService
//    
//    //ViewModel with DynamoDBService passed as a dependency
//  // @StateObject private var viewModel: UserSignInViewModel
//    
//    //initializer to inject the DynamoDBService into the viewModel
////    init(rootView: Binding<RootView>, dynamoDBService: DynamoDBService) {
////        _rootView = rootView
////        self.dynamoDBService = dynamoDBService
////        _viewModel = StateObject(wrappedValue: UserSignInViewModel(dynamoDBService: dynamoDBService))
////    }
//    
//    var body: some View {
//        VStack {
//            Spacer()
//            
//            Text("Secure Rental")
//                .font(.title)
//            
//            TextField("Email", text: $email)
//                .autocorrectionDisabled(true)
//                .textInputAutocapitalization(.never)
//                .padding()
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(Color.gray, lineWidth: 1)
//                )
//            
//            SecureField("Password", text: $password)
//                .autocorrectionDisabled(true)
//                .textInputAutocapitalization(.never)
//                .padding()
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(Color.gray, lineWidth: 1)
//                )
//            
//            Button(action: {
//                Task {
//                    self.rootView = .main
//                    //UNCOMMENT ONCE COMPLETE
//                    //await viewModel.signIn() // Call ViewModel's signIn method
//                }
//            }) {
//                Text("Log In")
//                    .padding(EdgeInsets(top: 6, leading: 5, bottom: 6, trailing: 5))
//                    .frame(maxWidth: .infinity)
//            }
//            .buttonStyle(.borderedProminent)
//            .background(Color.blue)
//            .cornerRadius(10)
//            .padding(.top, 24)
//            
//            Button(action: {
//                self.rootView = .signUp
//            }) {
//                Text("Don't have an account? Sign Up")
//                    .foregroundColor(.blue)
//            }
//            
//            Spacer()
//        }
//        .padding()
////        .alert(isPresented: $viewModel.showAlert) {
////            Alert(
////                title: Text("Error"),
////                message: Text(viewModel.alertMessage),
////                dismissButton: .default(Text("OK")) {
////                    viewModel.showAlert = false
////                }
////            )
////        }
//    }
//}
//
//
//
//
  

import SwiftUI
import Amplify

struct SignInView: View {
    
    @Binding var rootView: RootView
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Secure Rental")
                .font(.title)
            
            TextField("Email", text: $email)
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
            
            if isLoading {
                ProgressView()
                    .padding(.top, 24)
            } else {
                Button(action: signIn) {
                    Text("Log In")
                        .padding(EdgeInsets(top: 6, leading: 5, bottom: 6, trailing: 5))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.top, 24)
            }
            
            Button(action: {
                self.rootView = .signUp
            }) {
                Text("Don't have an account? Sign Up")
                    .foregroundColor(.blue)
            }
            
            Spacer()
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    showAlert = false
                }
            )
        }
    }
    
        // MARK: - Sign-In Action
    private func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Please enter both email and password."
            showAlert = true
            return
        }
        
        isLoading = true
        Task {
            do {
                let signInResult = try await Amplify.Auth.signIn(username: email, password: password)
                if signInResult.isSignedIn {
                    DispatchQueue.main.async {
                        rootView = .main // Navigate to the main view on success
                    }
                } else {
                    alertMessage = "Sign-in not complete. Please try again."
                    showAlert = true
                }
            } catch {
                alertMessage = "Sign-in failed: \(error.localizedDescription)"
                showAlert = true
            }
            isLoading = false
        }
    }
}
