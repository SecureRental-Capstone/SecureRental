//
//  LandingView.swift
//  SecureRental
//
//  Created by Shehnazdeep Kaur on 2024-12-06.
//
//
//import AuthenticationServices
//import SwiftUI
//
//struct LandingView: View {
//    @EnvironmentObject private var authenticationService: AuthenticationService
//    @State private var isLoading = true
//    
//    var body: some View {
//        ZStack {
//            
//            Color.white.ignoresSafeArea()
//            
//            if isLoading {
//                ProgressView()
//            }
//            Group {
//                if authenticationService.isSignedIn {
//                    LaunchView()
//                } else {
//                    Button("Sign in") {
//                        Task {
//                            await authenticationService.signIn(presentationAnchor: window)
//                        }
//                    }
//                }
//            }
//            .opacity(isLoading ? 0.5 : 1)
//            .disabled(isLoading)
//        }
//        .task {
//            isLoading = true
//            await authenticationService.fetchSession()
//            if !authenticationService.isSignedIn {
//                await authenticationService.signIn(presentationAnchor: window)
//            }
//            isLoading = false
//        }
//    }
//    
//    private var window: ASPresentationAnchor {
//        if let delegate = UIApplication.shared.connectedScenes.first?.delegate as? UIWindowSceneDelegate,
//           let window = delegate.window as? UIWindow {
//            return window
//        }
//        return ASPresentationAnchor()
//    }
//}
import AuthenticationServices
import SwiftUI

struct LandingView: View {
    @EnvironmentObject private var authenticationService: AuthenticationService
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
                // Background color or any other views you want to add
            Color.white.ignoresSafeArea()
            
            if isLoading {
                ProgressView()
            }
            
            Group {
                if authenticationService.isSignedIn {
                    LaunchView()
                } else {
                    VStack {
                        Spacer() // Add space to push the button towards the center
                        
                        Button(action: {
                            Task {
                                await authenticationService.signIn(presentationAnchor: window)
                            }
                        }) {
                            HStack {
                                Image("Logo")  // Use the name you gave to the image in Assets.xcassets
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                Text("Sign in")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                        }
                        .frame(maxWidth: .infinity)  // Button width will expand
                        .padding(.horizontal)  // Optional padding to ensure the button is not too wide
                        
                        Spacer() // Add space to push the button towards the center
                    }
                }
            }
            .opacity(isLoading ? 0.5 : 1)
            .disabled(isLoading)
        }
        .task {
            isLoading = true
            await authenticationService.fetchSession()
            if !authenticationService.isSignedIn {
                await authenticationService.signIn(presentationAnchor: window)
            }
            isLoading = false
        }
    }
    
    private var window: ASPresentationAnchor {
        if let delegate = UIApplication.shared.connectedScenes.first?.delegate as? UIWindowSceneDelegate,
           let window = delegate.window as? UIWindow {
            return window
        }
        return ASPresentationAnchor()
    }
}
