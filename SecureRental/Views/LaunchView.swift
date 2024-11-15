//
//  LaunchView.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2024-10-19.
//

//import SwiftUI
//
//struct LaunchView: View {
//    
//    @State private var rootView : RootView = .login
//        
//    var body: some View {
//        NavigationStack{
//            switch self.rootView{
//            case .signUp:
//                SignUpView(rootView: self.$rootView)
//            case .login:
//                SignInView(rootView: self.$rootView)
//            case .main:
//                HomeView(rootView: self.$rootView)
//            case .authentication:
//                Authentication(rootView: self.$rootView)
//            }
//        }
//    }
//}
//
//struct LaunchView_Previews: PreviewProvider {
//    static var previews: some View {
//        LaunchView()
//    }
//}

import SwiftUI

struct LaunchView: View {
    
    @State private var rootView: RootView = .login
    
    // Define your DynamoDB region and table name
    private let dynamoDBRegion = "us-west-2"  // Example region, replace with actual region
    private let dynamoDBTableName = "UsersTable"  // Example table name, replace with your actual table name
    
    private var dynamoDBService: DynamoDBService
    
    init() {
        // Initialize the DynamoDBService with region and table name
        dynamoDBService = DynamoDBService(region: dynamoDBRegion, tableName: dynamoDBTableName)
    }
    
    var body: some View {
        NavigationStack {
            switch self.rootView {
            case .signUp:
                SignUpView(rootView: self.$rootView, dynamoDBService: dynamoDBService)
            case .login:
                SignInView(rootView: self.$rootView, dynamoDBService: dynamoDBService)
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

