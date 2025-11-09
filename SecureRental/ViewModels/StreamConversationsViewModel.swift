import Foundation
import StreamChat

final class StreamConversationsViewModel: ObservableObject {
    @Published var channels: [ChatChannel] = []

    private var controller: ChatChannelListController?


    func loadMyChannels(currentUserId: String) {
            let client = StreamChatManager.shared.client

            // ✅ ask ONLY for channels where I'm a member
            let query = ChannelListQuery(
                filter: .containMembers(userIds: [currentUserId]),
                sort: [.init(key: .lastMessageAt, isAscending: false)]
            )

            let controller = client.channelListController(query: query)
            self.controller = controller

            controller.synchronize { [weak self] (error: Error?) in
                if let error = error {
                    print("❌ failed to load channels: \(error)")
                    return
                }
                self?.channels = Array(controller.channels)
            }

            controller.delegate = self
        }
}

extension StreamConversationsViewModel: ChatChannelListControllerDelegate {
    func controller(
        _ controller: ChatChannelListController,
        didChangeChannels changes: [ListChange<ChatChannel>]
    ) {
        self.channels = Array(controller.channels)
    }
}
