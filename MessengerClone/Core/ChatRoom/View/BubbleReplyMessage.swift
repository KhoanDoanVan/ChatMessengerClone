//
//  BubbleReplyMessage.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 16/10/24.
//

import SwiftUI
import Kingfisher

struct BubbleReplyMessage: View {
    
    let message: MessageItem
    
    var body: some View {
        HStack(alignment: .bottom) {
            if message.isNotMe {
                VStack {
                    
                }
                .frame(width: 40, height: 40)
            }

            if message.isNotMe {
                HStack {
                    replyBubbleBehind()
                        .opacity(0.65)
                    
                    Spacer()
                }
                
            } else {
                HStack {
                    Spacer()
                    replyBubbleBehind()
                        .opacity(0.65)
                }
            }

        }
        .frame(maxWidth: .infinity, alignment: message.alignment)
        .padding(.leading, message.leadingPadding)
        .padding(.trailing, message.trailingPadding)
        .padding(.bottom, message.emojis != nil ? 25 : 0)
    }
    
    /// Reply bubble behind main message
    private func replyBubbleBehind() -> some View {
        VStack {
            switch message.messageReplyType {
            case .textReply:
                textView()
                    .onAppear {
                        print("textReply")
                    }
            case .imageReply, .videoReply:
                imageView()
                    .onAppear {
                        print("imageReply")
                    }
            case .stickerReply:
                EmptyView()
                    .onAppear {
                        print("stickerReply")
                    }
            case .likeReply:
                EmptyView()
                    .onAppear {
                        print("likeReply")
                    }
            case .audioReply:
                EmptyView()
                    .onAppear {
                        print("audioReply")
                    }
            default:
                HStack {
                    Text("Attachment")
                    Image(systemName: "paperclip")
                }
                .onAppear {
                    print("default")
                }
                .font(.footnote)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .padding(.bottom, 20)
                .background(message.isNotMe ? .messagesGray : Color(.systemBlue))
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
            .padding(.bottom, 60)
    }
    
    /// Button Reaction
    private func buttonReaction() -> some View {
        Button {
            
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
}

#Preview {
    BubbleReplyMessage(message: .stubMessageImage)
}
