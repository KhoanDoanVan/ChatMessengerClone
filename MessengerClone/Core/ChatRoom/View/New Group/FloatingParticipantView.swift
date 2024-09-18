//
//  FloatingParticipantView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 17/9/24.
//

import SwiftUI
import StreamVideo
import StreamVideoSwiftUI

struct FloatingParticipantView: View {

    var participant: CallParticipant?
    var size: CGSize = .init(width: 120, height: 120)

    var body: some View {
        if let participant = participant {
            VStack {
                HStack {
                    Spacer()

                    VideoRendererView(
                        id: participant.id,
                        size: size
                    ) { videoRenderer in
                        videoRenderer.handleViewRendering(for: participant) { size, participant in
                            
                        }
                    }
                    .frame(width: size.width, height: size.height)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                Spacer()
            }
            .padding()
        }
    }
}

extension VideoRenderer {
    func handleViewRendering(
        for participant: CallParticipant,
        onTrackSizeUpdate: @escaping (CGSize, CallParticipant) -> ()
    ) {
        if let track = participant.track {
            log.debug("adding track to a view \(self)")
            self.add(track: track)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                let prev = participant.trackSize
                let scale = UIScreen.main.scale
                let newSize = CGSize(
                    width: self.bounds.size.width * scale,
                    height: self.bounds.size.height * scale
                )
                if prev != newSize {
                    onTrackSizeUpdate(newSize, participant)
                }
            }
        }
    }
}


public struct VideoCallParticipantModifier: ViewModifier {
    var participant: CallParticipant
    var call: Call?
    var availableFrame: CGRect
    var ratio: CGFloat
    var showAllInfo: Bool
    var decorations: Set<VideoCallParticipantDecoration>
    
    init(participant: CallParticipant, call: Call?, availableFrame: CGRect, ratio: CGFloat, showAllInfo: Bool, decorations: [VideoCallParticipantDecoration] = VideoCallParticipantDecoration.allCases) {
        self.participant = participant
        self.call = call
        self.availableFrame = availableFrame
        self.ratio = ratio
        self.showAllInfo = showAllInfo
        self.decorations = .init(decorations)
    }
    
    public func body(content: Content) -> some View {
        content
            .adjustVideoFrame(to: availableFrame.size.width, ratio: ratio)
            .overlay {
                ZStack {
                    BottomView {
                        HStack {
                            ParticipantInfoView(participant: participant, isPinned: participant.isPinned)
                            
                            Spacer()
                            
                            if showAllInfo {
                                ConnectionQualityIndicator(connectionQuality: participant.connectionQuality)
                            }
                        }
                    }
                }
            }
            .applyDecorationModifierIfRequired(
                VideoCallParticipantOptionsModifier(participant: participant, call: call),
                decoration: .options,
                availableDecorations: decorations
            )
            .applyDecorationModifierIfRequired(
                VideoCallParticipantSpeakingModifier(participant: participant, participantCount: participantCount),
                decoration: .speaking,
                availableDecorations: decorations
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .clipped()
    }
    
    @MainActor
    private var participantCount: Int {
        call?.state.participants.count ?? 0
    }
}
