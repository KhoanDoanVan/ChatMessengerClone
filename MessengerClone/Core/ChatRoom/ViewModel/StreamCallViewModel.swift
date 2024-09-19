//
//  StreamCallViewModel.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 19/9/24.
//

import Foundation
import StreamVideo
import StreamVideoSwiftUI

struct StreamCallConstants {
    static let apiKey: String = "mmhfdzb5evj2"
    static let token: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL3Byb250by5nZXRzdHJlYW0uaW8iLCJzdWIiOiJ1c2VyL1ByaW5jZXNzX0xlaWEiLCJ1c2VyX2lkIjoiUHJpbmNlc3NfTGVpYSIsInZhbGlkaXR5X2luX3NlY29uZHMiOjYwNDgwMCwiaWF0IjoxNzI2NzEzNzUyLCJleHAiOjE3MjczMTg1NTJ9.CFWu6UOAhaNZIqCYF0T1CwqhACnQUpvriZmxc4VkwHE"
}

@MainActor
class StreamCallViewModel: ObservableObject {
    // MARK: Properties
    @Published var call: Call
    @Published var callCreated: Bool = false
    @Published var token: String?
    @Published var state: CallState
    
    @Published var partner: UserItem
    
    // MARK: Init
    init (_ user: UserItem, _ partner: UserItem, _ channel: ChannelItem) {
        
        self.partner = partner
        
        let userCredentials = UserCredentials(
            user: User(
                id: user.uid,
                name: user.username,
                imageURL: URL(string: user.profileImage ?? "")
            ),
            token: .init(stringLiteral: StreamCallConstants.token)
        )
        
        // Initialize Stream Video client
        let streamVideo = StreamVideo(
            apiKey: StreamCallConstants.apiKey,
            user: userCredentials.user,
            token: userCredentials.token
        )

        // Initialize the call object
        let call = streamVideo.call(callType: "default", callId: channel.id)

        self.call = call
        self.state = call.state
    }
    
    /// Join Stream
    func joinStream() async throws {
        guard callCreated == false else { return }
        try await self.call.join(create: true)
        callCreated = true
    }
}
