//
//  StreamChatViewModel.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-11-08.
//

// StreamChatViewModel.swift
import Foundation
import StreamChat
import StreamChatUI
import FirebaseAuth
final class StreamChatViewModel: ObservableObject {
    @Published var channelController: ChatChannelController?

    func setupChannel(for listing: Listing, landlordId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        // this returns an optional, so unwrap safely
        guard let controller = StreamChatManager.shared.channelController(
            listingId: listing.id,
            landlordId: landlordId,
            tenantId: currentUserId,
            listingTitle: listing.title
        ) else {
            print("❌ Failed to create Stream channel controller.")
            return
        }

        // start syncing
        controller.synchronize { error in
            if let error = error {
                print("❌ Stream channel sync failed: \(error.localizedDescription)")
            } else {
                print("✅ Stream channel synchronized successfully.")
            }
        }

        // store for the view
        self.channelController = controller
    }
}
