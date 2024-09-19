//
//  StreamCallViewModel.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 19/9/24.
//

import Foundation
import StreamVideo
import StreamVideoSwiftUI
import Combine

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
    @Published var camera: Bool?
    @Published var microphone: Bool?
    @Published var speaker: Bool?
    
    // MARK: Time Video Call
    @Published var timeVideoCall: TimeInterval = 0
    @Published var startTime: Date?
    @Published var timer: AnyCancellable?
    @Published var elaspedTime: TimeInterval = 0
    
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
        
        self.camera = true
        self.microphone = true
        self.speaker = true
    }
    
    /// Join Stream
    func joinStream() async throws {
        guard callCreated == false else { return }
        try await self.call.join(create: true)
        self.state = call.state
        callCreated = true
        startTime = Date()
        timerStart()
    }
    
    /// Setup timer
    private func timerStart() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let startTime = self?.startTime else { return }
                self?.elaspedTime = Date().timeIntervalSince(startTime)
            }
    }
    
    /// Leave Stream
    func leaveStream() {
        self.call.leave()
        self.callCreated = false
        self.state = nil
        self.camera = nil
        self.microphone = nil
        self.speaker = nil
        self.timeVideoCall = elaspedTime
        elaspedTime = 0
        timer?.cancel()
    }
    
    // MARK: Camera
    /// Control Camera
    func controlCamera() async throws {
        if self.call.camera.status == .disabled {
            try await self.enableCamera()
        } else {
            try await self.disableCamera()
        }
    }
    
    /// Enable Camera
    private func enableCamera() async throws {
        do {
            try await self.call.camera.enable()
            camera = true
        } catch {
            print("Error control enable camera: \(error.localizedDescription)")
        }
    }
    
    /// Disable Camera
    private func disableCamera() async throws {
        do {
            try await self.call.camera.disable()
            camera = false
        } catch {
            print("Error control disable camera: \(error.localizedDescription)")
        }
    }
    
    // MARK: Microphone
    /// Control Microphone
    func controlMicrophone() async throws {
        if self.call.microphone.status == .disabled {
            try await self.enableMicrophone()
        } else {
            try await self.disableMicrophone()
        }
    }
    
    /// Enable Microphone
    private func enableMicrophone() async throws {
        do {
            try await self.call.microphone.enable()
            microphone = true
        } catch {
            print("Error control enable microphone: \(error.localizedDescription)")
        }
    }
    
    /// Disable Microphone
    private func disableMicrophone() async throws {
        do {
            try await self.call.microphone.disable()
            microphone = false
        } catch {
            print("Error control disable microphone: \(error.localizedDescription)")
        }
    }
    
    // MARK: Speaker
    /// Control Speaker
    func controlSpeaker() async throws {
        if self.call.speaker.status == .disabled {
            try await self.enableSpeaker()
        } else {
            try await self.disableSpeaker()
        }
    }
    
    /// Enable Microphone
    private func enableSpeaker() async throws {
        do {
            try await self.call.speaker.enableSpeakerPhone()
            speaker = true
        } catch {
            print("Error control enable Speaker: \(error.localizedDescription)")
        }
    }
    
    /// Disable Microphone
    private func disableSpeaker() async throws {
        do {
            try await self.call.speaker.disableSpeakerPhone()
            speaker = false
        } catch {
            print("Error control disable Speaker: \(error.localizedDescription)")
        }
    }
}
