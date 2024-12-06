//
//  SecureRentalApp.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2024-10-19.
//
import SwiftUI
import AWSCore
import AWSCognito
import AWSLex


@main
struct SecureRentalApp: App {
    
    init() {
        setupAWS()
    }
    
    var body: some Scene {
        WindowGroup {
            //LaunchView()
            ChatbotView()
        }
    }
    
    func setupAWS() {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "us-east-1:b0676120-667d-47a0-b265-65f95956900a")
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        let chatConfig = AWSLexInteractionKitConfig.defaultInteractionKitConfig(withBotName: "SecureRentalV", botAlias: "$LATEST")
        AWSLexInteractionKit.register(with: configuration!, interactionKitConfiguration: chatConfig, forKey: "chatConfig")
    }
}
