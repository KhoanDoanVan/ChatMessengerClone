//
//  BlurView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 5/9/24.
//

import SwiftUI
import Kingfisher
import AVKit
import Foundation
import Combine


struct BlurView: View {
    
    // MARK: Properties
    @State private var text: String = ""
    @State private var minimumAction: Bool = true
    
    let message: MessageItem
    let handleAction: (_ action: MessageListController.BlurMessageViewAction) -> Void
    
    init(message: MessageItem, handleAction: @escaping (_ action: MessageListController.BlurMessageViewAction) -> Void) {
        self.message = message
        self.handleAction = handleAction
        if let urlString = message.videoURL, let url = URL(string: urlString) {
            self._avPlayer = State(initialValue: AVPlayer(url: url))
        }
    }
    
    // MARK: Player Video Properties
    @State private var avPlayer: AVPlayer?
    @State private var playingVideo: Bool = false
    @State private var slidingVideo: Bool = false // Check the state of slide wheather holding move or not
    @State private var currentTime: TimeInterval = 0

    var body: some View {
        VStack {
            topNavigation()
            Spacer()
            
            if message.type == .video {
                ZStack {
                    CustomVideoPlayerView(player: avPlayer!)
                        .onAppear {
                            setupTimer(avPlayer!, slidingVideo)
                            addObserve()
                        }

                    sliderRange(
                        message.videoDuration ?? 0,
                        currentTime, 
                        playingVideo: $playingVideo
                    )
                    .zIndex(1)
                }
                .clipShape(
                    .rect(cornerRadius: 20)
                )
            }
            
            textInputBottom()
        }
        .padding(.horizontal)
    }
    
    /// Play, pause video
    private func playing() {
        if playingVideo {
            avPlayer?.pause()
            playingVideo = false
        } else {
            avPlayer?.play()
            playingVideo = true
        }
    }
    
    /// Setup Timer
    private func setupTimer(_ avPlayer: AVPlayer, _ slidingVideo: Bool) {
        avPlayer.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 600), queue: .main) { timer in
            if !slidingVideo {
                currentTime = CMTimeGetSeconds(timer)
            }
        }
    }
    
    /// Reset Video Player
    private func reset() {
        avPlayer?.pause()
        avPlayer?.seek(to: CMTime.zero)
        currentTime = 0
    }
    
    // Seek Audio (use when dragging and moving the slider)
    func seek(to timeInterval: TimeInterval) {
        let targetTime = CMTime(seconds: timeInterval, preferredTimescale: 1)
        avPlayer?.seek(to: targetTime)
    }
    
    /// Add Observe for when the video end
    private func addObserve() {
        NotificationCenter.default.addObserver(forName: AVPlayerItem.didPlayToEndTimeNotification, object: avPlayer?.currentItem, queue: .main) { _ in
            reset()
            avPlayer?.play()
            playingVideo = true
        }
    }
}

extension BlurView {
    /// Slider range
    private func sliderRange(
        _ duration: TimeInterval ,
        _ currentTime: TimeInterval,
        playingVideo: Binding<Bool>
    ) -> some View {
        VStack {
            Spacer()
            HStack(spacing: 10) {
                /// Button Play
                Button  {
                    playing()
                } label: {
                    Image(systemName: playingVideo.wrappedValue ? "pause.fill" : "play.fill")
                }
                .font(.title)
                
                /// Slider Range
                Slider(value: $currentTime, in: 0...duration, onEditingChanged: { editing in
                    slidingVideo = editing
                    if !editing {
                        /// Update the video player to seek to the new time
                        seek(to: currentTime)
                        
                        /// Resume playback if the video was playing before dragging
                        if playingVideo.wrappedValue {
                            avPlayer?.play()
                        }
                    } else {
                        /// Pause the video while sliding
                        avPlayer?.pause()
                    }
                })
                .frame(maxWidth: .infinity)
                .tint(.white)
                
                /// Timer
                Text(currentTime.formatElaspedTime)
                    .font(.footnote)
                    .monospacedDigit()
                    .bold()
            }
            .foregroundStyle(.white)
            .padding(10)
        }
    }
    
    /// Text input area
    private func textInputBottom() -> some View {
        HStack(spacing: 15) {
            if minimumAction {
                buttonCamera()
                buttonPhoto()
                buttonRecord()
            } else {
                Button {
                    minimumAction = true
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .bold()
                }
            }
            textField()
            
            if text.isEmpty {
                buttonEmoji()
            } else {
                Button {
                    
                } label: {
                    Image(systemName: "paperplane.fill")
                }
                .font(.title2)
                .bold()
            }
        }
        .animation(.easeInOut, value: minimumAction)
    }
    
    /// Top Navigation
    private func topNavigation() -> some View {
        HStack {
            buttonDismiss()
            Spacer()
            HStack(spacing: 20) {
                buttonSave()
                buttonMore()
            }
        }
    }
    
    
    /// TextField
    private func textField() -> some View {
        TextField("", text: $text, prompt: Text("Aa"))
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .padding(.trailing, 25)
            .background(.messagesGray)
            .cornerRadius(20)
            .overlay {
                HStack {
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "face.smiling")
                            .font(.title2)
                    }
                    .padding(.trailing, 5)
                }
            }
            .onTapGesture {
                minimumAction = false
            }
    }
    
    /// Emoji button
    private func buttonEmoji() -> some View {
        Button {
            
        } label: {
            Image(systemName: "hand.thumbsup.fill")
                .bold()
                .font(.title2)
        }
    }
    
    /// Camera button
    private func buttonCamera() -> some View {
        Button {
            
        } label: {
            Image(systemName: "camera.fill")
        }
        .bold()
        .font(.title2)
    }
    
    /// Camera photo
    private func buttonPhoto() -> some View {
        Button {
            
        } label: {
            Image(systemName: "photo.fill")
        }
        .bold()
        .font(.title2)
    }
    
    /// Camera record
    private func buttonRecord() -> some View {
        Button {
            
        } label: {
            Image(systemName: "mic.fill")
        }
        .bold()
        .font(.title2)
    }
    
    /// Dismiss button
    private func buttonDismiss() -> some View {
        Button {
            switch message.type {
            case .photo:
                handleAction(.closeBlurViewImage)
            case .video:
                handleAction(.closeBlurViewVideo)
            default:
                break
            }
        } label: {
            Image(systemName: "xmark")
                .bold()
                .font(.title2)
        }
    }
    
    /// Save button
    private func buttonSave() -> some View {
        Button {
            
        } label: {
            Image(systemName: "arrow.down.to.line")
                .bold()
                .font(.title2)
        }
    }
    
    /// More button
    private func buttonMore() -> some View {
        Button {
            
        } label: {
            Image(systemName: "ellipsis.circle")
                .bold()
                .font(.title2)
        }
    }
}


#Preview {
    BlurView(message: .stubMessageImage) { action in
        
    }
}
