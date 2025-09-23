//
//  UserSignInViewModel.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2024-11-15.
//

import Foundation
import Combine

//enum for different sign-in states
enum SignInState {
    case idle
    case signingIn
    case success
    case error(String)
}

class UserSignInViewModel: ObservableObject {
    
    //published properties for the view to observe
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var signInState: SignInState = .idle
    
    private var cancellables = Set<AnyCancellable>()
    
    //injected DynamoDBService instance
    private let dynamoDBService: DynamoDBService
    
    //initializer to inject dependencies
    init(dynamoDBService: DynamoDBService) {
        self.dynamoDBService = dynamoDBService
    }

    //function to handle user sign-in logic
    func signIn() {
        //validate email and password
        guard !email.isEmpty, !password.isEmpty else {
            signInState = .error("Please enter both email and password")
            return
        }
        
        signInState = .signingIn
        
        //call DynamoDBService to sign the user in
        dynamoDBService.signInUser(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let isSuccess):
                    if isSuccess {
                        self?.signInState = .success
                    } else {
                        self?.signInState = .error("Invalid credentials")
                    }
                case .failure(let error):
                    self?.signInState = .error("An error occurred: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func reset() {
        email = ""
        password = ""
        signInState = .idle
    }
}


