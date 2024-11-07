//
//  LaunchView.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2024-10-19.
//

import SwiftUI

struct LaunchView: View {
    
    @State private var rootView : RootView = .login
        
    var body: some View {
        NavigationStack{
            switch self.rootView{
            case .signUp:
                SignUpView(rootView: self.$rootView)
            case .login:
                SignInView(rootView: self.$rootView)
            case .main:
                HomeView(rootView: self.$rootView)
            case .authentication:
                Authentication(rootView: self.$rootView)
            }
        }
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
    }
}
