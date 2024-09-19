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

    @ObservedObject private var viewModel: StreamCallViewModel
    
    // MARK: View Model
    @StateObject var callViewModel = CallViewModel()

    init(_ user: UserItem, _ partner: UserItem, _ channel: ChannelItem) {
        self._viewModel = ObservedObject(wrappedValue: StreamCallViewModel(user, partner, channel))
    }

    var body: some View {
        VStack {
            if viewModel.callCreated && viewModel.state.participants.count > 1 {
                ZStack {
                    ParticipantsView(
                        call: viewModel.call,
                        participants: viewModel.call.state.remoteParticipants,
                        onChangeTrackVisibility: changeTrackVisibility(_:isVisible:)
                    )
                    FloatingParticipantView(participant: viewModel.call.state.localParticipant)
                    VStack {
                        Spacer()
                        makeCallControlsView(viewModel: callViewModel)
                    }
                }
            } else {
                ZStack {
                    screenWaiting()
                    VStack {
                        Spacer()
                        makeCallControlsView(viewModel: callViewModel)
                    }
                }
                .background(.fill)
            }
        }.onAppear {
            Task {
                try await viewModel.joinStream()
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
            CircularProfileImage(viewModel.partner.profileImage, size: .large)
            VStack(spacing: 0) {
                Text(viewModel.partner.username)
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
            await viewModel.call.changeTrackVisibility(for: participant, isVisible: isVisible)
        }
    }
    
    func makeCallControlsView(viewModel: CallViewModel) -> some View {
        CallControlsView(viewModel: viewModel)
    }
}
