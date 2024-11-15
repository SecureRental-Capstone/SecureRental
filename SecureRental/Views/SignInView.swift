//
//  SignInView.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2024-10-19.
//

import SwiftUI

struct SignInView: View {
    
    @Binding var rootView: RootView
    
    //init DynamoDBService with the region and table name
    private var dynamoDBService: DynamoDBService
    
    //ViewModel with DynamoDBService passed as a dependency
    @StateObject private var viewModel: UserSignInViewModel
    
    //initializer to inject the DynamoDBService into the viewModel
    init(rootView: Binding<RootView>, dynamoDBService: DynamoDBService) {
        _rootView = rootView
        self.dynamoDBService = dynamoDBService
        _viewModel = StateObject(wrappedValue: UserSignInViewModel(dynamoDBService: dynamoDBService))
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Secure Rental")
                .font(.title)
            
            TextField("Email", text: $viewModel.email)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
            
            SecureField("Password", text: $viewModel.password)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
            
            Button(action: {
                Task {
                    self.rootView = .main
                    //UNCOMMENT ONCE COMPLETE
                    //await viewModel.signIn() // Call ViewModel's signIn method
                }
            }) {
                Text("Log In")
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
//        .alert(isPresented: $viewModel.showAlert) {
//            Alert(
//                title: Text("Error"),
//                message: Text(viewModel.alertMessage),
//                dismissButton: .default(Text("OK")) {
//                    viewModel.showAlert = false
//                }
//            )
//        }
    }
}



//#Preview {
//    SignInView()
//}
