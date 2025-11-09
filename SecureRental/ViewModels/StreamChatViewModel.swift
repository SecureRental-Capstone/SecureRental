import SwiftUI
import StreamChat
import FirebaseAuth

@MainActor
final class StreamChatViewModel: ObservableObject {
    @Published var channelController: ChatChannelController?
    @Published var isLoading = false
    @Published var errorMessage: String?

    /// open existing channel OR create it if it doesn't exist yet
    func openOrCreateChannel(
        channelId: String,
        listing: Listing,
        landlordId: String
    ) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Not signed in."
            return
        }

        isLoading = true

        let cid = ChannelId(type: .messaging, id: channelId)
        let attachController = StreamChatManager.shared.client.channelController(for: cid)

        attachController.synchronize { [weak self] (error: Error?) in
            Task { @MainActor in
                guard let self = self else { return }

                if let error = error {
                    // channel doesn't exist -> create it
                    print("ℹ️ attach failed, will create: \(error)")
                    self.createChannel(
                        listing: listing,
                        landlordId: landlordId,
                        tenantId: currentUserId,
                        channelId: channelId
                    )
                } else {
                    // attached -> make sure I'M a member
                    self.isLoading = false
                    self.channelController = attachController
                    self.ensureIAmMember(controller: attachController, userId: currentUserId)
                }
            }
        }
    }

    private func createChannel(
        listing: Listing,
        landlordId: String,
        tenantId: String,
        channelId: String
    ) {
        StreamChatManager.shared.makeChannelController(
            listingId: listing.id,
            landlordId: landlordId,
            tenantId: tenantId,
            listingTitle: listing.title
        ) { [weak self] controller in
            Task { @MainActor in
                guard let self = self else { return }
                guard let controller = controller else {
                    self.isLoading = false
                    self.errorMessage = "Could not create chat channel."
                    return
                }

                controller.synchronize { (error: Error?) in
                    Task { @MainActor in
                        self.isLoading = false
                        if let error = error {
                            print("❌ channel sync after create failed: \(error)")
                            self.errorMessage = error.localizedDescription
                        } else {
                            self.channelController = controller
                            // ✅ after create, force-add the tenant
                            if let currentUserId = Auth.auth().currentUser?.uid {
                                self.ensureIAmMember(controller: controller, userId: currentUserId)
                            }
                        }
                    }
                }
            }
        }
    }

    /// Try to add myself as a member in case the server dropped members on create
    private func ensureIAmMember(controller: ChatChannelController, userId: String) {
        controller.addMembers(userIds: [userId]) { error in
            if let error = error {
                print("⚠️ ensureIAmMember failed: \(error)")
            } else {
                print("✅ ensureIAmMember succeeded for \(userId)")
            }
        }
    }
}
