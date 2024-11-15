//
//  ProfileViewModel.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2024-11-15.
//
import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var profile: Profile? //profile data
    @Published var isLoading: Bool = false //loading state
    @Published var errorMessage: String? //error message state
    
    private var dynamoDBService: DynamoDBService //service to fetch data
    
    init(dynamoDBService: DynamoDBService) {
        self.dynamoDBService = dynamoDBService
    }
    
    //fetch the profile from DynamoDB
    func fetchProfile(userId: String) {
        self.isLoading = true
        self.errorMessage = nil
        
        Task {
            do {
                //fetch profile from the database
                if let fetchedProfile = try await dynamoDBService.getProfile(userId: userId) {
                    self.profile = fetchedProfile //assign the profile data
                }
            } catch {
                self.errorMessage = "Failed to load profile: \(error.localizedDescription)" //show error message
            }
            
            self.isLoading = false //stop loading
        }
    }
    
    //function to update profile (e.g., save changes)
    func updateProfile(profile: Profile) {
        self.isLoading = true
        
        Task {
            do {
                //update profile in DynamoDB (e.g., you would need a method for that in DynamoDBService)
                try await dynamoDBService.updateProfile(profile: profile)
                self.profile = profile //if update is successful, update the local profile
            } catch {
                self.errorMessage = "Failed to update profile: \(error.localizedDescription)" //show error
            }
            
            self.isLoading = false //stop loading
        }
    }
}



