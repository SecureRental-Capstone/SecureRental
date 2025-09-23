//
//  SecureRentalApp.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2024-10-19.
//

import SwiftUI
import AWSCore

@main
struct SecureRentalApp: App {
    
    init() {
        // Set up AWS configuration (use your actual AWS credentials for real app)
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: "YOUR_ACCESS_KEY", secretKey: "YOUR_SECRET_KEY")
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    var body: some Scene {
        WindowGroup {
            LaunchView()
        }
    }
}
