//
//  StreamChatDetailView.swift
//  SecureRental
//
//  Created by Anchal  Sharma  on 2025-11-08.
//

// StreamChatDetailView.swift
import SwiftUI
import StreamChat
import StreamChatUI
import StreamChatSwiftUI


import SwiftUI
import StreamChatUI

struct StreamChatDetailView: View {
    let listing: Listing
    let landlordId: String
    let channelId: String

    @StateObject private var vm = StreamChatViewModel()

    var body: some View {
        Group {
            if let controller = vm.channelController {
                ChatChannelView(
                    viewFactory: DefaultViewFactory.shared,
                    channelController: controller
                )
            } else if vm.isLoading {
                ProgressView("Loading chat…")
            } else if let error = vm.errorMessage {
                Text(error).foregroundColor(.red)
            } else {
                Text("Loading…")
            }
        }
        .onAppear {
            vm.openOrCreateChannel(
                channelId: channelId,
                listing: listing,
                landlordId: landlordId
            )
        }
    }
}
