//
//  SecureRentalApp.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2024-10-19.
//

//import SwiftUI
//import Amplify
//
//@main
//struct SecureRentalApp: App {
//    
//    init() {
//        do {
//           try Amplify.configure()
//            print("Initialized Amplify");
//        } catch {
//            print("Could not initialize Amplify: \(error)")
//        }
//    }
//    
//    var body: some Scene {
//        WindowGroup {
//            LaunchView()
//        }
//    }
//}
  
import SwiftUI
import Amplify
import AWSCognitoAuthPlugin

@main
struct SecureRentalApp: App {
    
    init() {
        configureAmplify()
    }
    
    func configureAmplify() {
        do {
                
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            
            try Amplify.configure()
            print("Initialized Amplify successfully.")
        } catch {
            print("Could not initialize Amplify: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            LandingView()
                .environmentObject(AuthenticationService())
        }
    }
}

