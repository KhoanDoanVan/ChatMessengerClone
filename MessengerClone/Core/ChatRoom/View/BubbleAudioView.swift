//
//  BubbleAudioView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 3/9/24.
//

import SwiftUI
import AVFoundation

struct BubbleAudioView: View {
    
    let handleAction: (_ state: Bool, _ message: MessageItem) -> Void
        
    let message: MessageItem
    let isShowAvatarSender: Bool
    var levelsPreviewMain: [CGFloat] = []
    
    @Binding var bubbleMessageDidSelect: MessageItem?
    
    @State private var levelsPreviewPlay: [CGFloat] = []
    @State private var playingPreview: Bool = false
    @State private var elapsedTimePreview: TimeInterval = 0
    @State private var indexPos: Int = 0
    
    var urlAudio: URL?
    @State private var avAudioPlayer: AVAudioPlayer?
    
    /// State to manage the scale of the bubble
    @State private var isScaled = false
    
    init(message: MessageItem, isShowAvatarSender: Bool, bubbleMessageDidSelect: Binding<MessageItem?>, handleAction: @escaping (_ state: Bool, _ message: MessageItem) -> Void) {
        self.handleAction = handleAction
        self.message = message
        self.isShowAvatarSender = isShowAvatarSender
        self._bubbleMessageDidSelect = bubbleMessageDidSelect
        self.urlAudio = URL(string: message.audioURL ?? "")
        
        if let listLevelAudio = message.audioLevels {
            self.levelsPreviewMain = listLevelAudio.compactMap { normalizedAudioLevel(level: $0) }
        }
    }
    
    var body: some View {
        HStack(alignment: .bottom) {
            if message.isNotMe && isShowAvatarSender {
                CircularProfileImage(message.sender?.profileImage, size: .xSmall)
            } else if message.isNotMe {
                VStack {
                    
                }
                .frame(width: 40, height: 40)
            }
            
            if message.isNotMe {
                ZStack {
                    HStack {
                        frameAudio()
                            .scaleEffect(isScaled ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.35), value: isScaled)
                            .onAppear {
                                if bubbleMessageDidSelect?.messageReply?.id == message.id {
                                    scaleUpAndReset()
                                }
                            }
                            .padding(.horizontal, message.emojis != nil && message.isNotMe == false ? -8 : 0)
                        Spacer()
                    }
                    
                    if message.emojis != nil {
                        HStack {
                            VStack {
                                Spacer()
                                buttonReaction()
                                    .padding(.vertical, -15)
                                    .padding(
                                        .horizontal, 8
                                    )
                            }
                            Spacer()
                        }
                    }
                }
            } else {
                ZStack {
                    HStack {
                        Spacer()
                        frameAudio()
                            .scaleEffect(isScaled ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.35), value: isScaled)
                            .onAppear {
                                if bubbleMessageDidSelect?.messageReply?.id == message.id {
                                    scaleUpAndReset()
                                }
                            }
                            .padding(.horizontal, 0)
                    }
                    
                    if message.emojis != nil && message.isNotMe == false {
                        HStack {
                            Spacer()
                            VStack {
                                Spacer()
                                buttonReaction()
                                    .padding(.vertical, -15)
                                    .padding(
                                        .horizontal, 8
                                    )
                            }
                        }
                    }
                }
            }
            
        }
        .frame(maxWidth: .infinity, alignment: message.alignment)
        .padding(.leading, message.leadingPadding)
        .padding(.trailing, message.trailingPadding)
        .padding(.bottom, message.emojis != nil ? 25 : 0)
    }
    
    /// Setup scale with dispatchQueue
    private func scaleUpAndReset() {
        // Scale up
        withAnimation {
            isScaled = true
        }
        
        // After 1 second, reset the scale back to normal
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                isScaled = false
                bubbleMessageDidSelect = nil
            }
        }
    }
    
    /// Button Reaction
    private func buttonReaction() -> some View {
        Button {
            handleAction(true, message)
        } label: {
            HStack(spacing: 3) {
                ForEach(0..<min(message.emojis?.count ?? 0, 3), id: \.self) { index in
                    Text(message.emojis?[index].reaction ?? "")
                        .font(.footnote)
                }
                
                if (message.emojis?.count ?? 0) > 1 {
                    Text("\(message.emojis?.count ?? 0)")
                        .font(.footnote)
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal,8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color(.systemGray2)) // Main background
            )
            .overlay(
                Capsule()
                    .stroke(Color.black, lineWidth: 4) // Black stroke effect
            )
            .clipShape(Capsule())
        }
        .padding(.top)
    }
    
    /// Frame Audio
    private func frameAudio() -> some View {
        HStack(spacing: 20) {
            buttonPlay()
            
            ScrollView(.horizontal) {
                ScrollViewReader { proxy in
                    LazyHStack {
                        ZStack(alignment: .leading) {
                            fillLevel(message.audioLevels ?? [], color: .white.opacity(0.5))
                            
                            fillLevelPlay(levelsPreviewPlay, color: .white)
                        }
                        .onChange(of: indexPos) { oldValue, newValue in
                            withAnimation {
                                proxy.scrollTo(newValue, anchor: .center)
                            }
                        }
                    }
                }
            }
            .frame(width: 125)
            
            timer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemBlue))
        .clipShape(
            .rect(
                cornerRadii:
                        .init(
                            topLeading: message.isNotMe ? 5 : 20, bottomLeading: message.isNotMe ? 5 : 20,
                            bottomTrailing: message.isNotMe ? 20 : 5, topTrailing: message.isNotMe ? 20 : 5
                        )
            )
        )
    }
    
    /// Play, pause action
    private func buttonPlay() -> some View {
        Button {
            withAnimation {
                actionClickPlayAudio()
                if playingPreview {
                    fillLevelsPreviewAction(indexPos)
                }
            }
        } label: {
            Image(systemName: playingPreview ? "pause.fill" : "play.fill")
                .foregroundStyle(.white)
                .font(.title2)
        }
    }
    
    /// Timer
    @ViewBuilder
    private func timer() -> some View {
        if playingPreview {
            Text(elapsedTimePreview.formatElaspedTime)
                .foregroundStyle(.white)
                .bold()
                .monospacedDigit()
        } else {
            Text(elapsedTimePreview.formatElaspedTime == "00:00" ? (message.audioDuration?.formatElaspedTime ?? "") : elapsedTimePreview.formatElaspedTime)
                .foregroundStyle(.white)
                .bold()
                .monospacedDigit()
        }
    }
    
    /// Level fill with many columns
    private func fillLevel(_ levels: [Float], color: Color) -> some View {
        HStack(spacing: 2) {
            ForEach(Array(levels.enumerated()), id: \.offset) { index, level in
                Rectangle()
                    .frame(width: 1, height: normalizedAudioLevel(level: level))
                    .foregroundStyle(color)
                    .clipShape(Capsule())
                    .id(index)
            }
        }
    }
    
    /// Level fill with many columns
    private func fillLevelPlay(_ levels: [CGFloat], color: Color) -> some View {
        HStack(spacing: 2) {
            ForEach(Array(levels.enumerated()), id: \.offset) { index, level in
                Rectangle()
                    .frame(width: 1, height: level)
                    .foregroundStyle(color)
                    .clipShape(Capsule())
                    .id(index)
            }
        }
    }
}


extension BubbleAudioView {
    /// Normalize the audio level to a suitable height for the UI
    func normalizedAudioLevel(level: Float) -> CGFloat {
        let level = max(0.2, CGFloat(level + 45) / 2.5)
        return CGFloat(level * 2)
    }
    
    /// Action fill the list level
    private func fillLevelsPreviewAction(_ startIndex: Int) {
        var currentIndex = startIndex
        
        Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { timer in
            while playingPreview && currentIndex < levelsPreviewMain.count {
                
                let level = self.levelsPreviewMain[currentIndex]
                
                // If the level is not already added, append it and break out of the loop
                if !levelsPreviewPlay.contains(level) {
                    levelsPreviewPlay.append(level)
                    
                    indexPos = currentIndex
                    currentIndex += 1
                    /// check integer
                    self.elapsedTimePreview += 0.15
                    
                    break
                }
                
                // Otherwise, skip to the next level
                currentIndex += 1
            }
            
            // Stop the timer if all levels are processed or if playing is stopped
            if !playingPreview {
                timer.invalidate()
            }
            
            if currentIndex >= levelsPreviewMain.count {
                timer.invalidate()
                resetPreviewVoice()
            }
        }
    }
    
    /// Reset preview voice
    private func resetPreviewVoice() {
        playingPreview = false
        levelsPreviewPlay.removeAll()
        indexPos = 0
        elapsedTimePreview = 0
    }
    
    /// Action click audio voice
    private func actionClickPlayAudio() {
        if playingPreview == false {
            playSoundAudio(urlAudio)
            playingPreview = true
        } else {
            pauseSoundAudio()
            playingPreview = false
        }
    }
    
    /// Play Sound
    private func playSoundAudio(_ urlAudio: URL?) {
        if elapsedTimePreview != 0 {
            avAudioPlayer?.play()
        } else {
            guard let url = urlAudio else { return }
            
            DispatchQueue.global().async {
                if let audioData = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        do {
                            self.avAudioPlayer = try AVAudioPlayer(data: audioData)
                            self.avAudioPlayer?.play()
                        } catch {
                            print("Error play sound audio")
                        }
                    }
                } else {
                    print("Failed to download audio from \(url)")
                }
            }
        }
    }
    
    /// Pause Sound
    private func pauseSoundAudio() {
        avAudioPlayer?.pause()
    }
}

//#Preview {
//    BubbleAudioView(message: .stubMessageAudio, isShowAvatarSender: false){ state, message in
//        
//    }
//}
