//
//  SignUpView.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2024-10-19.
//
//import SwiftUI
//
//struct SignUpView: View {
//    
//    @Binding var rootView: RootView
//    
//    @State private var email: String = ""
//    @State private var password: String = ""
//    
//    @State private var showAlert = false
//    @State private var alertMessage = ""
//    
//   // private var dynamoDBService: DynamoDBService
//  //  @StateObject private var viewModel: UserSignUpViewModel
//    
//    //custom initializer to inject dependencies
////    init(rootView: Binding<RootView>, dynamoDBService: DynamoDBService) {
////        _rootView = rootView
////        self.dynamoDBService = dynamoDBService
////        _viewModel = StateObject(wrappedValue: UserSignUpViewModel(dynamoDBService: dynamoDBService))
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
//                    //await viewModel.createAccount(email: email, password: password)
//                }
//            }) {
//                Text("Create Account")
//                    .padding(EdgeInsets(top: 6, leading: 5, bottom: 6, trailing: 5))
//                    .frame(maxWidth: .infinity)
//            }
//            .buttonStyle(.borderedProminent)
//            .background(Color.blue)
//            .cornerRadius(10)
//            .padding(.top, 24)
//            
//            // Alert for errors
////            .alert(isPresented: $viewModel.showAlert) {
////                Alert(
////                    title: Text("Error"),
////                    message: Text(viewModel.alertMessage),
////                    dismissButton: .default(Text("OK")) {
////                        viewModel.showAlert = false
////                    }
////                )
////            }
//            
//            //Already have an account Button
//            Button(action: {
//                self.rootView = .login
//            }) {
//                Text("Already have an account? Log In")
//                    .foregroundColor(.blue)
//            }
//            
//            Spacer()
//        }
//        .padding()
//    }
//}
//
////#Preview {
////    SignUpView()
////}


import SwiftUI

struct SignUpView: View {
    @Binding var rootView: RootView
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?
    @State private var showAlert: Bool = false
    @EnvironmentObject var dbHelper : FireDBHelper

    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Create an Account")
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
            
            SecureField("Confirm Password", text: $confirmPassword)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
            
            Button(action: {
                Task {
                    await signUp()
                }
            }) {
                Text("Sign Up")
                    .padding(EdgeInsets(top: 6, leading: 5, bottom: 6, trailing: 5))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.top, 24)
            
            Button(action: {
                self.rootView = .login
            }) {
                Text("Already have an account? Log In")
                    .foregroundColor(.blue)
            }
            
            Spacer()
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage ?? "An unexpected error occurred."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func signUp() async {
        // Insert user
        let newUser = AppUser(username: email, email: email, name: "John Doe")
        await dbHelper.insertUser(user: newUser)
        
        // Fetch user by UID
        if let user = await dbHelper.getUser(byUID: newUser.id) {
            print(user.name)
        }
    }
}
