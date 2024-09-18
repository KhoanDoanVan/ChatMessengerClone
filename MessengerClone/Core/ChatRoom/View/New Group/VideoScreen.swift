//
//  VideoScreen.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 17/9/24.
//


import SwiftUI
import StreamVideo
import StreamVideoSwiftUI

struct VideoScreen: View {
    @State var call: Call
    @ObservedObject var state: CallState
    @State var callCreated: Bool = false
    private var client: StreamVideo
    private let apiKey: String = "mmhfdzb5evj2"
    private let token: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL3Byb250by5nZXRzdHJlYW0uaW8iLCJzdWIiOiJ1c2VyL0V4YXJfS3VuIiwidXNlcl9pZCI6IkV4YXJfS3VuIiwidmFsaWRpdHlfaW5fc2Vjb25kcyI6NjA0ODAwLCJpYXQiOjE3MjY2MzY3ODgsImV4cCI6MTcyNzI0MTU4OH0.hRSXGcC6gPVaml00Pk2THc_NPPAEe-T4DHAke18-Rfg"
    private let callId: String = "pE6mv8NIuCPM"
    
    // Hello
    
    // MARK: View Model
    @ObservedObject var viewModel = CallViewModel()
    
    // MARK: Properties
    @State private var user: UserItem
    @State private var partner: UserItem

    init(_ user: UserItem, _ partner: UserItem) {
        self.user = user
        self.partner = partner
        
        let user = User(
            id: user.uid,
            name: user.username,
            imageURL: URL(string: user.profileImage ?? "")
        )

        // Initialize Stream Video client
        self.client = StreamVideo(
            apiKey: apiKey,
            user: user,
            token: .init(stringLiteral: token)
        )

        // Initialize the call object
        let call = client.call(callType: "default", callId: callId)

        self.call = call
        self.state = call.state
    }

    var body: some View {
        VStack {
            if callCreated && state.participants.count > 1 {
                ZStack {
                    ParticipantsView(
                        call: call,
                        participants: call.state.remoteParticipants,
                        onChangeTrackVisibility: changeTrackVisibility(_:isVisible:)
                    )
                    FloatingParticipantView(participant: call.state.localParticipant)
                    VStack {
                        Spacer()
                        makeCallControlsView(viewModel: viewModel)
                    }
                }
            } else {
                ZStack {
                    screenWaiting()
                    VStack {
                        Spacer()
                        makeCallControlsView(viewModel: viewModel)
                    }
                }
                .background(.fill)
            }
        }.onAppear {
            Task {
                guard callCreated == false else { return }
                try await call.join(create: true)
                callCreated = true
            }
        }
    }
    
    /// Screen Waiting
    private func screenWaiting() -> some View {
        VStack(spacing: 50) {
            HStack(spacing: 20) {
                Button {
                    
                } label: {
                    Image(systemName: "chevron.down")
                        .foregroundStyle(.white)
                        .font(.title2)
                }
                Spacer()
                HStack {
                    Button {
                        
                    } label: {
                        Image(systemName: "person.fill.badge.plus")
                            .foregroundStyle(.white)
                            .font(.title2)
                    }
                    Button {
                        
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(.white)
                            .font(.title2)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            centerViewImageUser()
            
            Spacer()
        }
    }
    
    /// Image and Name User at center screen
    private func centerViewImageUser() -> some View {
        VStack(spacing: 10) {
            CircularProfileImage(partner.profileImage, size: .large)
            VStack(spacing: 0) {
                Text(partner.username)
                    .font(.title)
                    .bold()
                    .foregroundStyle(.white)
                Text("Calling...")
            }
        }
    }
}

extension VideoScreen {
    /// Changes the track visibility for a participant (not visible if they go off-screen).
    /// - Parameters:
    ///  - participant: the participant whose track visibility would be changed.
    ///  - isVisible: whether the track should be visible.
    private func changeTrackVisibility(_ participant: CallParticipant?, isVisible: Bool) {
        guard let participant else { return }
        Task {
            await call.changeTrackVisibility(for: participant, isVisible: isVisible)
        }
    }
    
    func makeCallControlsView(viewModel: CallViewModel) -> some View {
        CallControlsView(viewModel: viewModel)
    }
}
