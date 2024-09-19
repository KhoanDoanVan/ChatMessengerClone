//
//  BubbleVideoCallView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 19/9/24.
//

import SwiftUI

struct BubbleVideoCallView: View {
    
    let message: MessageItem
    let isShowAvatarSender: Bool
    
    var body: some View {
        HStack(alignment: .bottom) {
            if message.isNotMe && isShowAvatarSender {
                CircularProfileImage(message.sender?.profileImage, size: .xSmall)
            } else if message.isNotMe {
                VStack {
                    
                }
                .frame(width: 40, height: 40)
            }
            
            HStack {
                Image(systemName: "phone.arrow.down.left.fill")
                    .padding(10)
                    .font(.title2)
                    .background(Color(.systemGray2))
                    .clipShape(Circle())
                
                VStack(alignment: .leading ,spacing: 0) {
                    Text("Video call")
                        .bold()
                        .foregroundStyle(.white)
                    Text(message.videoCallDuration?.formattedTimeDurationVideoCall() ?? "0 sec")
                        .foregroundStyle(Color(.systemGray))
                        .font(.footnote)
                }
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .clipShape(
                .rect(cornerRadius: 20)
            )
        }
        .frame(maxWidth: .infinity, alignment: message.alignment)
        .padding(.leading, message.leadingPadding)
        .padding(.trailing, message.trailingPadding)
    }
}

#Preview {
    BubbleVideoCallView(message: .stubMessageAudio, isShowAvatarSender: true)
}
