//
//  BubbleUnsentView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 20/10/24.
//

import SwiftUI

struct BubbleUnsentView: View {
    
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
                        unsentBubbleText
                            .padding(.horizontal, message.emojis != nil && message.isNotMe == false ? -8 : 0)
                        Spacer()
                    }
                }
            } else {
                ZStack {
                    HStack {
                        Spacer()
                        unsentBubbleText
                            .padding(.horizontal, 0)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: message.alignment)
        .padding(.leading, message.leadingPadding)
        .padding(.trailing, message.trailingPadding)
    }
    
    /// Unsent bubble message
    private var unsentBubbleText: some View {
        ZStack {
            Text("\(message.isNotMe ? message.sender?.username ?? "Unknown" : "You") unsent a message")
                .padding(.horizontal, 13)
                .padding(.vertical, 9)
                .background(Color.gray.opacity(0.55))
                .clipShape(
                    .rect(
                        cornerRadius: 20
                    )
                )
            
            Text("\(message.isNotMe ? message.sender?.username ?? "Unknown" : "You") unsent a message")
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.black)
                .foregroundStyle(Color.gray)
                .clipShape(
                    .rect(
                        cornerRadius: 20
                    )
                )
        }
    }
}

#Preview {
    BubbleUnsentView(message: .stubMessageTextIsMe, isShowAvatarSender: false) { state, message in
        
    }

}
