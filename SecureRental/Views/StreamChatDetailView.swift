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


struct StreamChatDetailView: View {
    let listing: Listing
    let landlordId: String

    // wrap Stream’s controller in an ObservableObject
    @StateObject private var streamVM = StreamChatViewModel()

    var body: some View {
        Group {
            if let channelController = streamVM.channelController {
                // Stream has a ready-made UIKit controller, we can wrap it
                ChatChannelView(channelController: channelController)
                    .edgesIgnoringSafeArea(.bottom)
            } else {
                ProgressView("Loading chat…")
            }
        }
        .onAppear {
            streamVM.setupChannel(for: listing, landlordId: landlordId)
        }
        .navigationTitle(listing.title)
    }
}

