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
    
    @Published var partner: UserItem
    
    // MARK: Properties
    @Published var call: Call
    @Published var callCreated: Bool = false
    @Published var token: String?
    @Published var state: CallState?
    
    // MARK: Camera and Microphone
    @Published var camera: CameraManager?
    @Published var microphone: MicrophoneManager?
    @Published var speaker: SpeakerManager?
    
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
        
        self.camera = call.camera
        self.microphone = call.microphone
        self.speaker = call.speaker
    }
    
    /// Join Stream
    func joinStream() async throws {
        guard callCreated == false else { return }
        try await self.call.join(create: true)
        self.state = call.state
        callCreated = true
    }
    
    /// Leave Stream
    func leaveStream() {
        self.call.leave()
        self.callCreated = false
        self.state = nil
        self.camera = nil
        self.microphone = nil
        self.speaker = nil
    }
    
    // MARK: Camera
    /// Control Camera
    func controlCamera() async throws {
        if self.camera?.status == .disabled {
            try await self.enableCamera()
        } else {
            try await self.disableCamera()
        }
    }
    
    /// Enable Camera
    private func enableCamera() async throws {
        do {
            try await self.camera?.enable()
        } catch {
            print("Error control enable camera: \(error.localizedDescription)")
        }
    }
    
    /// Disable Camera
    private func disableCamera() async throws {
        do {
            try await self.camera?.enable()
        } catch {
            print("Error control disable camera: \(error.localizedDescription)")
        }
    }
    
    // MARK: Microphone
    /// Control Microphone
    func controlMicrophone() async throws {
        if self.microphone?.status == .disabled {
            try await self.enableMicrophone()
        } else {
            try await self.disableMicrophone()
        }
    }
    
    /// Enable Microphone
    private func enableMicrophone() async throws {
        do {
            try await self.microphone?.enable()
        } catch {
            print("Error control enable microphone: \(error.localizedDescription)")
        }
    }
    
    /// Disable Microphone
    private func disableMicrophone() async throws {
        do {
            try await self.microphone?.enable()
        } catch {
            print("Error control disable microphone: \(error.localizedDescription)")
        }
    }
    
    // MARK: Speaker
    /// Control Speaker
    func controlSpeaker() async throws {
        if self.speaker?.status == .disabled {
            try await self.enableSpeaker()
        } else {
            try await self.disableSpeaker()
        }
    }
    
    /// Enable Microphone
    private func enableSpeaker() async throws {
        do {
            try await self.speaker?.enableSpeakerPhone()
        } catch {
            print("Error control enable Speaker: \(error.localizedDescription)")
        }
    }
    
    /// Disable Microphone
    private func disableSpeaker() async throws {
        do {
            try await self.speaker?.disableSpeakerPhone()
        } catch {
            print("Error control disable Speaker: \(error.localizedDescription)")
        }
    }
}
