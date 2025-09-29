//
//  UserSignUpViewModel.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2024-11-15.
//

import Foundation

class UserSignUpViewModel: ObservableObject {
    
    @Published var showAlert = false
    @Published var alertMessage = ""
    
   // private var dynamoDBService: DynamoDBService
    
    //init with DynamoDBService
//    init(dynamoDBService: DynamoDBService) {
//        self.dynamoDBService = dynamoDBService
//    }
    
    //method to create the user account
    func createAccount(email: String, password: String) async {
        //input validation
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Email and password cannot be empty."
            showAlert = true
            return
        }
        
        //create new user
        let newUser = AppUser(username: "john123", email: "john@example.com", name: "John Doe")
        do {
            //call the DynamoDBService to add the user
            //try await dynamoDBService.addUser(user: newUser)
            //if successful, navigate to the login screen or show a success message
            alertMessage = "Account created successfully!"
            showAlert = true
            //navigate to main or login once successful
            //self.rootView = .main
        } catch {
            alertMessage = "Failed to create account: \(error.localizedDescription)"
            showAlert = true
        }
    }
}
