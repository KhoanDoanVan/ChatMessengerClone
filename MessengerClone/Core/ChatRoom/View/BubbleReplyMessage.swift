//
//  BubbleReplyMessage.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 16/10/24.
//

import SwiftUI
import Kingfisher

struct BubbleReplyMessage: View {
    
    let messageReply: MessageItem
    let messageCurrent: MessageItem
//    private var replyMessagePreview: String {
//        let maxChar = 30
//        let trailingChars = viewModel.messageReply?.text.count > maxChar ? "..." : ""
//        let title = String(viewModel.messageReply?.text.prefix(maxChar) + trailingChars)
//        
//        return title
//    }
    
    var body: some View {
        HStack(alignment: .bottom) {
            if messageCurrent.isNotMe {
                VStack {}
                .frame(width: 40, height: 40)
            }

            if messageCurrent.isNotMe {
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
        .frame(maxWidth: .infinity, alignment: messageCurrent.alignment)
        .padding(.leading, messageCurrent.leadingPadding)
        .padding(.trailing, messageCurrent.trailingPadding)
        .padding(.bottom, messageCurrent.emojis != nil ? 25 : 0)
    }
    
    /// Reply bubble behind main message
    private func replyBubbleBehind() -> some View {
        VStack {
            switch messageCurrent.messageReplyType {
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
                .background(messageCurrent.isNotMe ? .messagesGray : Color(.systemBlue))
                .clipShape(
                    .rect(
                        cornerRadii:
                                .init(
                                    topLeading: messageCurrent.isNotMe ? 5 : 20,
                                    bottomLeading: messageCurrent.isNotMe ? 5 : 20,
                                    bottomTrailing: messageCurrent.isNotMe ? 20 : 5,
                                    topTrailing: messageCurrent.isNotMe ? 20 : 5
                                )
                    )
                )
                .shadow(radius: 10)
            }
        }
    }
    
    /// Text
    private func textView() -> some View {
        Text(messageReply.text)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .foregroundStyle(.messagesBlack)
            .clipShape(
                .rect(
                    cornerRadii:
                            .init(
                                topLeading: messageCurrent.isNotMe ? 5 : 20,
                                bottomLeading: messageCurrent.isNotMe ? 5 : 20,
                                bottomTrailing: messageCurrent.isNotMe ? 20 : 5,
                                topTrailing: messageCurrent.isNotMe ? 20 : 5
                            )
                )
            )
            .shadow(radius: 10)
            .padding(.bottom, 60)
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
                if messageReply.videoURL != nil {
                    Image(systemName: "play.fill")
                        .foregroundStyle(.white)
                        .padding()
                        .background(Color(.black).opacity(0.3))
                        .clipShape(Circle())
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if messageReply.videoURL != nil {
                    Text(messageReply.durationVideoString)
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
        VStack {
            if let thumbnailUrl = messageReply.thumbnailUrl, let url = URL(string: thumbnailUrl) {
                        KFImage(url)
                            .resizable()
                            .placeholder {
                                ProgressView()
                            }
                            .scaledToFill()
                            .frame(width: messageReply.imageSize.width, height: messageReply.imageSize.height)
                    } else {
                        // Show placeholder or fallback UI
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: 200, height: 100)
                            .overlay(
                                Text("No Image")
                                    .foregroundColor(.white)
                            )
                    }
        }
//        KFImage(URL(string: viewModel.messageReply?.thumbnailUrl ?? "https://images.pexels.com/photos/974266/pexels-photo-974266.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"))
//            .resizable()
//            .placeholder {
//                ProgressView()
//            }
//            .onAppear {
//                print("Image Thumbnail: \(viewModel.messageReply?.thumbnailUrl)")
//            }
//            .scaledToFill()
//            .frame(width: viewModel.messageReply?.imageSize.width ?? 200, height: viewModel.messageReply?.imageSize.height ?? 100)
    }
}

//#Preview {
//    BubbleReplyMessage(.stubMessageImage, .placeholder)
//}
