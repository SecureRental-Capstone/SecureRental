//
//  LaunchView.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2025-09-22.
//

import SwiftUI

struct LaunchView: View {
    
    @State private var rootView : RootView = .login
    
    let fireDBHelper : FireDBHelper = FireDBHelper.getInstance()
    
    var body: some View {
        NavigationStack{
            switch self.rootView{
            case .signUp:
                SignUpView(rootView: self.$rootView).environmentObject(self.fireDBHelper)
            case .login:
                SignInView(rootView: self.$rootView).environmentObject(self.fireDBHelper)
            case .main:
                HomeView(rootView: self.$rootView).environmentObject(self.fireDBHelper)
            }
        }
    }
}
