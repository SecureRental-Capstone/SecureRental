////
////  StreamChatManager.swift
////  SecureRental
////
////  Created by Anchal Sharma on 2025-11-08.
////
//
//import StreamChat
//import StreamChatUI
//import UIKit
//import FirebaseAuth
//
//final class StreamChatManager {
//    static let shared = StreamChatManager()
//
//    // Stream client
//    let client: ChatClient
//
//    private init() {
//        // 1. your Stream API key
//        let config = ChatClientConfig(apiKey: .init("acpt4mkqnv66"))
//
//        // 2. create client
//        client = ChatClient(config: config)
//
//        // ❌ don’t connect here with a dev token
//        // we’ll connect later when we actually have a valid token
//        print("ℹ️ StreamChatManager created – call connectCurrentFirebaseUser() or connect(userId:name:token:) later.")
//    }
//
//    // OPTION A: simple helper – call this right after Firebase login,
//    // but ONLY if your Stream app is in DEVELOPMENT and dev tokens are allowed.
//    func connectCurrentFirebaseUserWithDevToken() {
//        guard let uid = Auth.auth().currentUser?.uid else {
//            print("⚠️ No Firebase user yet, can’t connect to Stream.")
//            return
//        }
//
//        client.connectUser(
//            userInfo: .init(id: uid),
//            token: .development(userId: uid)
//        ) { error in
//            if let error = error {
//                print("❌ Stream connect (dev token) failed:", error)
//            } else {
//                print("✅ Stream connected with dev token")
//            }
//        }
//    }
//
//    // OPTION B (recommended for Production):
//    // you fetch a real token from YOUR backend, then call this.
//    func connect(userId: String, name: String? = nil, streamToken: String) {
//        var info = UserInfo(id: userId)
//        if var name { info.name = name }
//
//        client.connectUser(
//            userInfo: info,
//            token: .init(stringLiteral: streamToken)
//        ) { error in
//            if let error = error {
//                print("❌ Stream connect failed:", error)
//            } else {
//                print("✅ Stream connected")
//            }
//        }
//    }
//
//    // Get (or create) a 1:1 channel for this listing
//    func channelController(
//        listingId: String,
//        landlordId: String,
//        tenantId: String,
//        listingTitle: String
//    ) -> ChatChannelController? {
//
//        // stable id so we don’t make duplicates
//        let channelId = ChannelId(
//            type: .messaging,
//            id: "listing-\(listingId)-\(landlordId)-\(tenantId)"
//        )
//
//        do {
//            let controller = try client.channelController(
//                createChannelWithId: channelId,
//                name: listingTitle,
//                members: [landlordId, tenantId],
//                extraData: ["listingId": .string(listingId)]
//            )
//            return controller
//        } catch {
//            print("❌ Failed to create or fetch channel controller: \(error.localizedDescription)")
//            return nil
//        }
//    }
//}
//
//  StreamChatManager.swift
//  SecureRental
//
//  Created by Anchal Sharma on 2025-11-08.
//

import StreamChat
import StreamChatUI
import FirebaseAuth

final class StreamChatManager {
    static let shared = StreamChatManager()

    // Expose the client so views / VMs can use it
    let client: ChatClient

    private init() {
        // 1. use your real (production) Stream API key here
        var config = ChatClientConfig(apiKey: .init("acpt4mkqnv66"))
        // (optional) config.isClientInActiveMode = true

        // 2. create client – but do NOT connect yet
        client = ChatClient(config: config)
    }

    // MARK: - Connect user (called AFTER you get token from your backend)
    func connect(userId: String, name: String, streamToken: String) {
        client.connectUser(
            userInfo: .init(id: userId, name: name),
            token: .init(stringLiteral: streamToken)
        ) { error in
            if let error = error {
                print("❌ Stream connect failed: \(error)")
            } else {
                print("✅ Stream connected as \(userId)")
            }
        }
    }

    // MARK: - Optional: disconnect
    func disconnect() {
        client.disconnect()
    }

    // MARK: - Channel helper
    /// Get (or create) a 1:1 channel for this listing
    func channelController(
        listingId: String,
        landlordId: String,
        tenantId: String,
        listingTitle: String
    ) -> ChatChannelController? {

        // stable channel id – so we don't create duplicates
        let channelId = ChannelId(
            type: .messaging,
            id: "listing-\(listingId)-\(landlordId)-\(tenantId)"
        )

        do {
            // create-or-get style controller
            let controller = try client.channelController(
                createChannelWithId: channelId,
                name: listingTitle,
                members: [landlordId, tenantId],
                extraData: ["listingId": .string(listingId)]
            )

            // you still need to call `synchronize()` on the controller where you use it
            return controller
        } catch {
            print("❌ Failed to create/get channel controller: \(error.localizedDescription)")
            return nil
        }
    }
}
