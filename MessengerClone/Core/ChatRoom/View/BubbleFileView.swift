//
//  BubbleFileView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 14/10/24.
//

import SwiftUI

struct BubbleFileView: View {
    
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
                        bubbleFile()
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
                        bubbleFile()
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
    private func bubbleFile() -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "doc.text.fill")
                .foregroundStyle(Color(.systemGray))
                .font(.title3)
                .padding(12)
                .background(Color(.systemGray3))
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(message.nameOfFile ?? "Unknown")
                    .bold()
                Text(message.sizeOfFile?.toStringSizeOfFile() ?? "0 KB")
                    .foregroundStyle(Color(.systemGray))
                    .font(.callout)
            }
        }
        .padding(20)
        .background(Color(.systemGray6))
        .clipShape(
            .rect(cornerRadius: 15)
        )
    }
}
//
//#Preview {
//    BubbleFileView(message: .stubMessageFile, isShowAvatarSender: true) { state, message in
//        
//    }
//}
