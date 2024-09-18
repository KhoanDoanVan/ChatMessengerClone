//
//  TextInputArea.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 9/8/24.
//

import SwiftUI
import AVFoundation

struct TextInputArea: View {
    @Binding var text: String
    @State private var minimumAction: Bool = false
    @Binding var isRecording: Bool
    @Binding var audioLevels: [CGFloat]
    @Binding var elaspedTime: TimeInterval
    
    
    let onAction: (_ action: UserAction) -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            if isRecording && !minimumAction {
                buttonDeleteVoice()
            }
            else if !minimumAction {
                buttonMore()
                buttonCamera()
                buttonPhoto()
                buttonVoice()
            }
            else {
                Button {
                    minimumAction = false
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                }
            }
            
            if isRecording {
                recordingField()
            } else {
                textField()
            }
            
            if isRecording {
                buttonSendMessage()
            }
            else if text.isEmpty {
                buttonEmoji()
            } else {
                buttonSendMessage()
            }
        }
        .padding(.horizontal, 5)
        .animation(.bouncy, value: minimumAction)
        .animation(.bouncy, value: isRecording)
    }
    
    /// Send button
    private func buttonSendMessage() -> some View {
        Button {
            onAction(.sendTextMessage)
            minimumAction = false
        } label: {
            Image(systemName: "paperplane.fill")
                .font(.title2)
        }
        .frame(width: 30, height: 30)
    }
    
    /// Emoji button
    private func buttonEmoji() -> some View {
        Button {
            
        } label: {
            Image(systemName: "hand.thumbsup.fill")
                .font(.title2)
        }
        .frame(width: 30, height: 30)
    }
    
    /// Delete button
    private func buttonDeleteVoice() -> some View {
        Button {
            onAction(.deleteRecording)
        } label: {
            Image(systemName: "trash.fill")
                .font(.title2)
        }
        .frame(width: 30, height: 30)
    }
    
    /// Voice recording
    private func recordingField() -> some View {
        HStack(spacing: 10) {
            Button {
                onAction(.stopRecording)
            } label: {
                Image(systemName: "pause")
                    .font(.footnote)
                    .bold()
                    .padding(8)
                    .background(.white)
                    .clipShape(Circle())
            }
            HStack(spacing: 2) {
                ForEach(Array(audioLevels.enumerated()), id: \.offset) { index, level in
                    if index == 0 || index == 35 {
                        Capsule()
                            .fill(.white)
                            .frame(width: 3, height: 4)
                            .animation(
                                .easeInOut(duration: 0.3).delay(0.05),
                                value: level
                            )
                    } else if index == 1 || index == 34 {
                        Capsule()
                            .fill(.white)
                            .frame(width: 3, height: 8)
                            .animation(
                                .easeInOut(duration: 0.3).delay(0.05),
                                value: level
                            )
                    } else {
                        Capsule()
                            .fill(.white)
                            .frame(width: 3, height: level)
                            .animation(
                                .easeInOut(duration: 0.3).delay(0.05),
                                value: level
                            )
                    }
                    
                }
            }
            .animation(.linear, value: audioLevels)
            .frame(maxWidth: .infinity, alignment: .leading)
            Text(elaspedTime.formatElaspedTime)
                .font(.footnote)
                .bold()
                .foregroundStyle(.white)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 35)
        .padding(.horizontal, 5)
        .background(Color(.systemBlue))
        .cornerRadius(20)
    }
    
    /// TextField
    private func textField() -> some View {
        TextField("", text: $text, prompt: Text("Aa"))
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
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
                minimumAction = true
            }
    }
    
    /// Voice button
    private func buttonVoice() -> some View {
        Button {
            onAction(.startRecording)
        } label: {
            Image(systemName: "mic.fill")
                .font(.title2)
        }
    }
    
    /// Photo Picker button
    private func buttonPhoto() -> some View {
        Button {
            withAnimation {
                onAction(.presentPhotoPicker)
            }
        } label: {
            Image(systemName: "photo")
                .font(.title2)
        }
    }
    
    /// Take Photo button
    private func buttonCamera() -> some View {
        Button {
            
        } label: {
            Image(systemName: "camera.fill")
                .font(.title2)
        }
    }
    
    /// More button
    private func buttonMore() -> some View {
        Button {
            
        } label: {
            Image(systemName: "plus")
                .padding(4)
                .foregroundStyle(.messagesWhite)
                .background(Color(.systemBlue))
                .clipShape(Circle())
        }
    }
}

extension TextInputArea {
    enum UserAction {
        case sendTextMessage
        case presentPhotoPicker
        case sendImagesMessage
        case pickerAttachment(_ attachment: MediaAttachment)
        case startRecording
        case stopRecording
        case deleteRecording
        case deletePreviewRecording
        case reRecord
        case actionPreviewRecord
        case sendRecord
    }
}

#Preview {
    TextInputArea(text: .constant(""), isRecording: .constant(false), audioLevels: .constant([]), elaspedTime: .constant(0)) { action in
        
    }
}
