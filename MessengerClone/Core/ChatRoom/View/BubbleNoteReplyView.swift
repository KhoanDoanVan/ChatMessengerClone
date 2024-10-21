//
//  BubbleNoteReplyView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 13/10/24.
//

import SwiftUI
import Kingfisher

struct BubbleNoteReplyView: View {
    let message: MessageItem
    let isShowAvatarSender: Bool
    @Binding var bubbleMessageDidSelect: MessageItem?
    
    let handleAction: (_ state: Bool, _ message: MessageItem) -> Void
    
    /// State to manage the scale of the bubble
    @State private var isScaled = false
    
    private var noteTextPreview: String {
        let maxChar = 30
        let trailingChars = message.textNote?.count ?? 0 > maxChar ? "..." : ""
        let noteText = String(message.textNote!.prefix(maxChar) + trailingChars)
        
        return noteText
    }
        
    var body: some View {
        HStack(alignment: .bottom) {
            if message.isNotMe && isShowAvatarSender {
                CircularProfileImage(message.sender?.profileImage ,size: .xSmall)
            } else if message.isNotMe {
                VStack {
                    
                }
                .frame(width: 40, height: 40)
            }
            
            if message.isNotMe {
                ZStack {
                    ZStack {
                        HStack {
                            Text(noteTextPreview)
                                .font(.footnote)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .clipShape(
                                    .rect(cornerRadii: .init(
                                        topLeading: 15,
                                        bottomLeading: 5,
                                        bottomTrailing: 5,
                                        topTrailing: 15
                                    ))
                                )
                                .opacity(0.75)
                            Spacer()
                        }
                        HStack {
                            textView()
                                .scaleEffect(isScaled ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 0.35), value: isScaled)
                                .onAppear {
                                    if bubbleMessageDidSelect?.messageReply?.id == message.id {
                                        scaleUpAndReset()
                                    }
                                }
                                .padding(.horizontal, message.emojis != nil && message.isNotMe == false ? -8 : 0)
                                .padding(.top, 60)
                            Spacer()
                        }
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
                    ZStack {
                        HStack {
                            Spacer()
                            Text(noteTextPreview)
                                .font(.footnote)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .clipShape(
                                    .rect(cornerRadii: .init(
                                        topLeading: 15,
                                        bottomLeading: 5,
                                        bottomTrailing: 5,
                                        topTrailing: 15
                                    ))
                                )
                                .opacity(0.75)
                        }
                        HStack {
                            Spacer()
                            textView()
                                .scaleEffect(isScaled ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 0.35), value: isScaled)
                                .onAppear {
                                    if bubbleMessageDidSelect?.messageReply?.id == message.id {
                                        scaleUpAndReset()
                                    }
                                }
                                .padding(.horizontal, 0)
                                .padding(.top, 60)
                        }
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
        .onChange(of: bubbleMessageDidSelect ?? .stubMessageText) { oldSelectedMessage,newSelectedMessage in
            if newSelectedMessage.messageReply?.id == message.id {
                scaleUpAndReset()
            }
        }
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
    
    /// Text
    private func textView() -> some View {
        Text(message.text)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(message.isNotMe ? .messagesGray : Color(.systemBlue))
            .foregroundStyle(.messagesBlack)
            .clipShape(
                .rect(
                    cornerRadii:
                            .init(
                                topLeading: message.isNotMe ? 5 : 20,
                                bottomLeading: message.isNotMe ? 5 : 20,
                                bottomTrailing: message.isNotMe ? 20 : 5,
                                topTrailing: message.isNotMe ? 20 : 5
                            )
                )
            )
            .shadow(radius: 10)
    }
}

//#Preview {
//    BubbleNoteReplyView(message: .stubMessageReplyNote, isShowAvatarSender: false) { state, message in
//        
//    }
//}
