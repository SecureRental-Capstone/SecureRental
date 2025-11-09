//  SecureRentalApp.swift
//  SecureRental
//
//  Created by Haniya Akhtar on 2024-10-19.
//

import SwiftUI
import FirebaseCore
import StreamChat
import StreamChatSwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct SecureRentalApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    // we just HOLD the StreamChat wrapper here
    @State private var streamChat: StreamChat?

    init() {
        // we already have a singleton that builds ChatClient
        let client = StreamChatManager.shared.client
        // create the SwiftUI context object
        _streamChat = State(wrappedValue: StreamChat(chatClient: client))
        // ⚠️ notice: we are NOT connecting a user here
    }

    var body: some Scene {
        WindowGroup {
//            if let streamChat {
//                // make StreamChat available to the whole app
//                LaunchView()
//                    .environmentObject(streamChat)
//            } else {
                // super defensive fallback
                LaunchView()
//            }
        }
    }
}
