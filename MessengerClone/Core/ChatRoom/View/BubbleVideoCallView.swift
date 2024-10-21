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
    @Binding var bubbleMessageDidSelect: MessageItem?
    
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
            .scaleEffect(isScaled ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.35), value: isScaled)
            .onAppear {
                if bubbleMessageDidSelect?.messageReply?.id == message.id {
                    scaleUpAndReset()
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
}

//#Preview {
//    BubbleVideoCallView(message: .stubMessageAudio, isShowAvatarSender: true)
//}
