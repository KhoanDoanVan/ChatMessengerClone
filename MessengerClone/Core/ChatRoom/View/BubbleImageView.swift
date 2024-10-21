//
//  BubbleImageView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 11/8/24.
//

import SwiftUI
import Kingfisher

struct BubbleImageView: View {
    
    let message: MessageItem
    let isShowAvatarSender: Bool
    @Binding var bubbleMessageDidSelect: MessageItem?
    
    let handleAction: (_ state: Bool, _ message: MessageItem) -> Void
    
    /// State to manage the scale of the bubble
    @State private var isScaled = false
        
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
                        imageView()
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
                        imageView()
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
    
    /// Image View
    private func imageView() -> some View {
        imageMessage()
            .clipShape(
                .rect(
                    cornerRadii:
                            .init(
                                topLeading: 20,
                                bottomLeading: 20,
                                bottomTrailing: 20,
                                topTrailing: 20
                            )
                )
            )
            .overlay {
                if message.videoURL != nil {
                    Image(systemName: "play.fill")
                        .foregroundStyle(.white)
                        .padding()
                        .background(Color(.black).opacity(0.3))
                        .clipShape(Circle())
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if message.videoURL != nil {
                    Text(message.durationVideoString)
                        .foregroundStyle(.white)
                        .bold()
                        .font(.footnote)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(.black).opacity(0.45))
                        .clipShape(Capsule())
                        .padding(8)
                }
            }
    }
    
    /// Image Message
    private func imageMessage() -> some View {
        KFImage(URL(string: message.thumbnailUrl ?? ""))
            .resizable()
            .placeholder {
                ProgressView()
            }
            .scaledToFill()
            .frame(width: message.imageSize.width, height: message.imageSize.height)
    }
    
    /// Button share
    private func shareButton() -> some View {
        Button {
            
        } label: {
            Image(systemName: "square.and.arrow.up")
                .bold()
                .padding(10)
                .background(.messagesGray)
                .clipShape(Circle())
                .foregroundStyle(.messagesBlack)
        }
    }
}

//#Preview {
//    BubbleImageView(message: .stubMessageImage, isShowAvatarSender: false) { state, message in
//        
//    }
//}
