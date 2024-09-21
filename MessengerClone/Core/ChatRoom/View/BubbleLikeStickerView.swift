//
//  BubbleLikeStickerView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 21/9/24.
//

import SwiftUI

struct BubbleEmojiView: View {
    
    let message: MessageItem
    let isShowAvatarSender: Bool
    
    let handleAction: (_ state: Bool, _ message: MessageItem) -> Void
    
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
                    HStack {
                        emojiView()
                            .padding(.horizontal, message.emojis != nil && message.isNotMe == false ? -8 : 0)
                        Spacer()
                    }
                    
                    if message.emojis != nil {
                        HStack {
                            VStack {
                                Spacer()
                                buttonReaction()
                                    .padding(.vertical, -15)
                                    .padding(.horizontal, 8)
                            }
                            Spacer()
                        }
                    }
                }
            } else {
                ZStack {
                    HStack {
                        Spacer()
                        emojiView()
                            .padding(.horizontal, 0)
                    }
                    
                    if message.emojis != nil && message.isNotMe == false {
                        HStack {
                            Spacer()
                            VStack {
                                Spacer()
                                buttonReaction()
                                    .padding(.vertical, -15)
                                    .padding(.horizontal, 8)
                            }
                        }
                    }
                }
            }
        }
        .shadow(color: Color(.systemGray3).opacity(0.1), radius: 5, x: 0, y: 20)
        .frame(maxWidth: .infinity, alignment: message.alignment)
        .padding(.leading, message.leadingPadding)
        .padding(.trailing, message.trailingPadding)
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
    
    /// Emoji View
    private func emojiView() -> some View {
        Image(systemName: message.emojiString ?? "")
            .foregroundStyle(message.isNotMe ? .messagesGray : Color(.systemBlue))
            .font(.system(size: 42))
    }
}

#Preview {
    BubbleEmojiView(message: .stubMessageImage, isShowAvatarSender: true) {
        state, message in
        
    }
}
