import SwiftUI
import StreamChat
import StreamChatUI
import FirebaseAuth
@MainActor
final class StreamChatViewModel: ObservableObject {
    @Published var channelController: ChatChannelController?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func setupChannel(for listing: Listing, landlordId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Not signed in."
            return
        }

        isLoading = true
        StreamChatManager.shared.makeChannelController(
            listingId: listing.id,
            landlordId: landlordId,
            tenantId: currentUserId,
            listingTitle: listing.title
        ) { [weak self] controller in
            Task { @MainActor in
                guard let self = self else { return }
                self.isLoading = false
                guard let controller = controller else {
                    self.errorMessage = "Could not create chat channel."
                    return
                }

                self.isLoading = true
                controller.synchronize { error in
                    Task { @MainActor in
                        self.isLoading = false
                        if let error = error {
                            print("❌ Stream channel sync failed: \(error)")
                            self.errorMessage = error.localizedDescription
                        } else {
                            self.channelController = controller
                        }
                    }
                }
            }
        }
    }
}
