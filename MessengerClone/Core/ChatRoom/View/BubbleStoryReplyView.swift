//
//  BubbleStoryReplyView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 12/10/24.
//

import SwiftUI
import Kingfisher

struct BubbleStoryReplyView: View {
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
                    ZStack {
                        HStack {
                            KFImage(URL(string: message.urlImageStory ?? ""))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 130, height: 200)
                                .opacity(0.65)
                                .clipShape(
                                    .rect(cornerRadius: 15)
                                )
                            Spacer()
                        }
                        HStack {
                            textView()
                                .padding(.horizontal, message.emojis != nil && message.isNotMe == false ? -8 : 0)
                                .padding(.top, 180)
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
                            KFImage(URL(string: message.urlImageStory ?? ""))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 130, height: 200)
                                .opacity(0.65)
                                .clipShape(
                                    .rect(cornerRadius: 15)
                                )
                        }
                        HStack {
                            Spacer()
                            textView()
                                .padding(.top, 180)
                                .padding(.horizontal, 0)
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

#Preview {
    BubbleStoryReplyView(message: .stubMessageText, isShowAvatarSender: false) { state, message in
        
    }
}
