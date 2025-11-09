import StreamChat
import FirebaseAuth

final class StreamChatManager {
    static let shared = StreamChatManager()

    let client: ChatClient
    private(set) var isConnected = false

    private init() {
        let config = ChatClientConfig(apiKey: .init("mvjkgnhbeuhz")) // your dev key
        self.client = ChatClient(config: config)
    }

    // call AFTER Firebase sign-in
    func connect(userId: String, name: String?) {
        client.connectUser(
            userInfo: .init(id: userId, name: name),
            token: .development(userId: userId)
        ) { [weak self] error in
            if let error = error {
                print("❌ Stream connect error: \(error)")
                return
            }
            print("✅ Stream connected as \(userId)")
            self?.isConnected = true

            self?.client.currentUserController().reloadUserIfNeeded { err in
                if let err = err {
                    print("⚠️ reloadUserIfNeeded error: \(err)")
                } else {
                    print("✅ Stream current user is ready")
                }
            }
        }
    }

    /// Make a channel for this listing. For now: only the current user is a member.
    func makeChannelController(
        listingId: String,
        landlordId: String,   // we'll keep it in extraData
        tenantId: String,
        listingTitle: String,
        completion: @escaping (ChatChannelController?) -> Void
    ) {
        guard isConnected else {
            print("⚠️ Stream not connected yet")
            completion(nil)
            return
        }

        // ensure current user is loaded
        client.currentUserController().reloadUserIfNeeded { [weak self] error in
            guard let self = self else {
                completion(nil)
                return
            }

            if let error = error {
                print("⚠️ reloadUserIfNeeded before channel failed: \(error)")
                completion(nil)
                return
            }

            // shorten id so it's < 64 chars
            let shortListing = String(listingId.prefix(12))
            let shortTenant = String(tenantId.prefix(12))
            let channelId = "lst-\(shortListing)-t-\(shortTenant)"

            do {
                let controller = try self.client.channelController(
                    createChannelWithId: ChannelId(type: .messaging, id: channelId),
                    name: listingTitle,
                    // 👇 only current user is a member for now
                    members: [tenantId],
                    // 👇 store landlordId & full listingId in extraData
                    extraData: [
                        "listingId": .string(listingId),
                        "landlordId": .string(landlordId)
                    ]
                )
                completion(controller)
            } catch {
                print("❌ Failed to create/fetch channel controller: \(error)")
                completion(nil)
            }
        }
    }
}
