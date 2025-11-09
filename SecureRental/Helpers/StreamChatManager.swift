// StreamChatManager.swift
import StreamChat
import FirebaseAuth
import FirebaseFirestore

final class StreamChatManager {
    static let shared = StreamChatManager()

    let client: ChatClient
    private(set) var isConnected = false
    private var db: Firestore { Firestore.firestore() }

    private init() {
        let config = ChatClientConfig(apiKey: .init("mvjkgnhbeuhz"))
        self.client = ChatClient(config: config)
    }

    func connect(userId: String, name: String?) {
        client.connectUser(
            userInfo: .init(id: userId, name: name),
            token: .development(userId: userId)
        ) { [weak self] (error: Error?) in
            if let error = error {
                print("❌ Stream connect error: \(error)")
                return
            }
            print("✅ Stream connected as \(userId)")
            self?.isConnected = true
            self?.client.currentUserController().reloadUserIfNeeded { _ in }
        }
    }

    // TENANT creates channel (same as you had, you can keep your try-both-members version)
//    func makeChannelController(
//        listingId: String,
//        landlordId: String,
//        tenantId: String,
//        listingTitle: String,
//        completion: @escaping (ChatChannelController?) -> Void
//    ) {
//        guard isConnected else {
//            completion(nil); return
//        }
//
//        client.currentUserController().reloadUserIfNeeded { [weak self] _ in
//            guard let self = self else { completion(nil); return }
//
//            let shortListing = String(listingId.prefix(12))
//            let shortTenant  = String(tenantId.prefix(12))
//            let channelId = "lst-\(shortListing)-t-\(shortTenant)"
//            let cid = ChannelId(type: .messaging, id: channelId)
//
//            do {
//                let controller = try self.client.channelController(
//                    createChannelWithId: cid,
//                    name: listingTitle,
//                    members: [tenantId],
//                    extraData: [
//                        "listingId": .string(listingId),
//                        "landlordId": .string(landlordId),
//                        "tenantId": .string(tenantId)
//                    ]
//                )
//
//                // save for landlord
//                self.saveConversationToFirestore(
//                    channelId: channelId,
//                    listingId: listingId,
//                    landlordId: landlordId,
//                    tenantId: tenantId,
//                    listingTitle: listingTitle
//                )
//
//                completion(controller)
//            } catch {
//                print("❌ create channel failed: \(error)")
//                completion(nil)
//            }
//        }
//    }
    func makeChannelController(
        listingId: String,
        landlordId: String,
        tenantId: String,
        listingTitle: String,
        completion: @escaping (ChatChannelController?) -> Void
    ) {
        guard isConnected else {
            print("⚠️ Stream not connected yet")
            completion(nil)
            return
        }

        client.currentUserController().reloadUserIfNeeded { [weak self] _ in
            guard let self = self else { completion(nil); return }

            let shortListing = String(listingId.prefix(12))
            let shortTenant  = String(tenantId.prefix(12))
            let channelId = "lst-\(shortListing)-t-\(shortTenant)"
            let cid = ChannelId(type: .messaging, id: channelId)

            do {
                let controller = try self.client.channelController(
                    createChannelWithId: cid,
                    name: listingTitle,
                    members: [tenantId, landlordId],   // try both
                    extraData: [
                        "listingId": .string(listingId),
                        "landlordId": .string(landlordId),
                        "tenantId": .string(tenantId)
                    ]
                )

                // save in Firestore
                self.saveConversationToFirestore(
                    channelId: channelId,
                    listingId: listingId,
                    landlordId: landlordId,
                    tenantId: tenantId,
                    listingTitle: listingTitle
                )

                // ✅ after create, also try to add tenant again
                controller.addMembers(userIds: [tenantId, landlordId]) { err in
                    if let err = err {
                        print("⚠️ makeChannelController addMembers tenant failed: \(err)")
                    } else {
                        print("✅ tenant ensured as member")
                    }
                }

                completion(controller)
            } catch {
                print("❌ create channel failed: \(error)")
                completion(nil)
            }
        }
    }

    private func saveConversationToFirestore(
        channelId: String,
        listingId: String,
        landlordId: String,
        tenantId: String,
        listingTitle: String
    ) {
        db.collection("streamConversations").document(channelId).setData([
            "channelId": channelId,
            "listingId": listingId,
            "landlordId": landlordId,
            "tenantId": tenantId,
            "listingTitle": listingTitle,
            "createdAt": FieldValue.serverTimestamp()
        ]) { err in
            if let err = err {
                print("❌ failed to write convo: \(err)")
            } else {
                print("✅ saved convo \(channelId)")
            }
        }
    }

    /// LANDLORD: attach to existing channel and add self as member
    func joinExistingChannelAsLandlord(
        channelId: String,
        listingId: String,
        landlordId: String,
        tenantId: String
    ) {
        let cid = ChannelId(type: .messaging, id: channelId)
        let controller = client.channelController(for: cid)

        controller.synchronize { error in
            if let error = error {
                print("❌ landlord sync existing failed: \(error)")
                return
            }
            // try to add missing members (will no-op if already there)
            controller.addMembers(userIds: [landlordId, tenantId]) { error in
                if let error = error {
                    print("⚠️ addMembers failed: \(error)")
                } else {
                    print("✅ landlord joined existing channel")
                }
            }
        }
    }
}
