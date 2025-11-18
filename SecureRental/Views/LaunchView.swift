//
//  LaunchView.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2025-09-22.
//

import SwiftUI

struct LaunchView: View {
    
    @State private var rootView : RootView = .splash
    
    let fireDBHelper : FireDBHelper = FireDBHelper.getInstance()
    
    var body: some View {
        
        NavigationStack{
            switch self.rootView{
            case .splash:
                SplashView()
                    .onAppear {
                            // After animation delay, go to login
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                self.rootView = .login
                            }
                        }
                    }
                
            case .signUp:
                SignUpView(rootView: self.$rootView).environmentObject(self.fireDBHelper)
                
            case .login:
                SignInView(rootView: self.$rootView).environmentObject(self.fireDBHelper)
                
            case .main:
//                HomeView(rootView: self.$rootView).environmentObject(self.fireDBHelper)
                SecureRentalHomePage().environmentObject(self.fireDBHelper)

                
//            case .signUp:
//                SignUpView(rootView: self.$rootView).environmentObject(self.fireDBHelper)
//            case .login:
//                SignInView(rootView: self.$rootView).environmentObject(self.fireDBHelper)
//            case .main:
//                HomeView(rootView: self.$rootView).environmentObject(self.fireDBHelper)
            }
        }
    }
}
