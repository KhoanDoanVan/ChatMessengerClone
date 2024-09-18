//
//  PreviewVoiceRecordView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 30/8/24.
//

import Foundation
import SwiftUI


struct PreviewVoiceRecordView: View {
    @Environment(\.dismiss) private var dismiss
    let urlRecord: URL
    let levelsPreview: [CGFloat]
    @State private var fillLevelsPreview: [CGFloat] = []
    @State private var indexPos: Int = 0
    @Binding var playingPreview: Bool
    @Binding var elapsedTimePreview: TimeInterval
    @Binding var audioDuration: TimeInterval
    
    let onAction: (_ action: TextInputArea.UserAction) -> Void
    
    var body: some View {
        VStack {
            Text("Slide finger on recording to play from any point.")
                .font(.footnote)
                .foregroundStyle(Color.gray)
                .padding(.bottom, 30)
            
            slideRecord()
            
            HStack {
                HStack(spacing: 20) {
                    buttonDelete()
                    buttonReRecord()
                }
                Spacer()
                buttonSend()
            }
            .padding(.top, 30)
            .padding(.horizontal)
        }
        .padding()
    }
    
    /// Slide record
    private func slideRecord() -> some View {
        HStack {
            HStack {
                buttonPlay()
                Spacer()
                ScrollView(.horizontal) {
                    ScrollViewReader { proxy in
                        LazyHStack {
                            ZStack {
                                fillLevel(levelsPreview, color: .gray)
                                
                                fillLevel(fillLevelsPreview, color: .black)
                            }
                        }
                        .onChange(of: indexPos) { oldValue, newValue in
                            withAnimation {
                                proxy.scrollTo(newValue, anchor: .center)
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .frame(width: 170)
                Spacer()
                timer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .padding(.horizontal)
            .background(Color(.systemGray5))
            .clipShape(
                .rect(cornerRadii: .init(topLeading: 15,bottomLeading: 15))
            )
            
            Image(systemName: "mic.fill")
                .frame(width: 50)
                .frame(height: 50)
                .background(Color(.systemGray5))
                .clipShape(
                    .rect(cornerRadii: .init(bottomTrailing: 15,topTrailing: 15))
                )
        }
        .frame(maxWidth: .infinity)
    }
    
    /// Level fill with many columns
    private func fillLevel(_ levels: [CGFloat], color: Color) -> some View {
        HStack(spacing: 2) {
            ForEach(Array(levels.enumerated()), id: \.offset) { index, level in
                Rectangle()
                    .frame(width: 3, height: level)
                    .foregroundStyle(color)
                    .clipShape(Capsule())
                    .id(index)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    /// Timer
    private func timer() -> some View {
        if playingPreview {
            Text(elapsedTimePreview.formatElaspedTime)
                .font(.footnote)
                .monospacedDigit()
        } else {
            Text(elapsedTimePreview.formatElaspedTime == "00:00" ? audioDuration.formatElaspedTime : elapsedTimePreview.formatElaspedTime)
                .font(.footnote)
                .monospacedDigit()
        }
    }
    
    /// Play
    private func buttonPlay() -> some View {
        Button {
            withAnimation {
                playingPreview.toggle()
                onAction(.actionPreviewRecord)
                if playingPreview {
                    fillLevelsPreviewAction(indexPos)
                }
            }
        } label: {
            Image(systemName: playingPreview ? "pause.fill" : "play.fill")
                .foregroundStyle(.white)
        }
    }
    
    /// Delete
    private func buttonDelete() -> some View {
        Button {
            dismiss()
            resetPreviewVoice()
            onAction(.deletePreviewRecording)
        } label: {
            Image(systemName: "trash.fill")
                .foregroundColor(Color(.systemRed))
                .bold()
                .font(.title2)
        }
    }
    
    /// New record
    private func buttonReRecord() -> some View {
        Button {
            dismiss()
            resetPreviewVoice()
            onAction(.reRecord)
        } label: {
            Image(systemName: "goforward")
                .foregroundColor(Color(.systemBlue))
                .bold()
                .font(.title2)
        }
    }
    
    /// Send
    private func buttonSend() -> some View {
        Button {
            dismiss()
            resetPreviewVoice()
            onAction(.sendRecord)
        } label: {
            Image(systemName: "paperplane.fill")
                .font(.title2)
        }
    }
}

extension PreviewVoiceRecordView {
    private func fillLevelsPreviewAction(_ startIndex: Int) {
        
        var currentIndex = startIndex

        Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { timer in
            while playingPreview && currentIndex < levelsPreview.count {
                let level = self.levelsPreview[currentIndex]
                
                // If the level is not already added, append it and break out of the loop
                if !fillLevelsPreview.contains(level) {
                    fillLevelsPreview.append(level)
                    
                    indexPos = currentIndex
                    currentIndex += 1
                    /// check integer
                    elapsedTimePreview += 0.15
                    
                    break
                }
                
                // Otherwise, skip to the next level
                currentIndex += 1
            }

            // Stop the timer if all levels are processed or if playing is stopped
            if !playingPreview {
                timer.invalidate()
            }
            
            if currentIndex >= levelsPreview.count {
                timer.invalidate()
                resetPreviewVoice()
            }
        }
    }
    
    /// Reset preview voice
    private func resetPreviewVoice() {
        playingPreview = false
        fillLevelsPreview.removeAll()
        indexPos = 0
        elapsedTimePreview = 0
    }
}

#Preview {
    PreviewVoiceRecordView(urlRecord: URL(string: "")!, levelsPreview: [], playingPreview: .constant(false), elapsedTimePreview: .constant(0), audioDuration: .constant(0)) { action in
        
    }
}
