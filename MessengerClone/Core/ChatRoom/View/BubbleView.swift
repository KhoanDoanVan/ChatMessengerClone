//
//  BubbleView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 9/8/24.
//

import SwiftUI

struct BubbleView: View {
    
    let message: MessageItem
    let channel: ChannelItem
    let isNewDay: Bool
    let isShowNameSender: Bool
    let isShowAvatarSender: Bool
    @ObservedObject var viewModel: ChatRoomScreenViewModel
    
    let handleAction: (_ state: Bool, _ message: MessageItem) -> Void
    
    // State to manage the scale of the bubble
    @State private var isScaled = false
    
    var body: some View {
        VStack {
            if isNewDay {
                showNewDay()
            }
            
            /// Check message unsent
            if message.unsentIsContainMe {
                if message.isUnsentUids?.count == 1 {
                    VStack {
                        
                    }
                } else {
                    VStack(alignment: message.isNotMe ? .leading : .trailing, spacing: 0) {
                        BubbleUnsentView(
                            message: message,
                            isShowAvatarSender: isShowAvatarSender) { state, message in
                                
                            }
                    }
                }
            } else {
                switch message.type {
                case .replyNote:
                    VStack(alignment: message.isNotMe ? .leading : .trailing, spacing: 0) {
                        
                        showTextReplyNote()
                        
                        composeDynamicBubbleView()
                    }
                case .replyStory:
                    VStack(alignment: message.isNotMe ? .leading : .trailing, spacing: 0) {
                        
                        showTextReplyStory()
                        
                        composeDynamicBubbleView()
                    }
                default:
                    VStack(alignment: message.isNotMe ? .leading : .trailing, spacing: 0) {
                        
                        if message.uidMessageReply != nil {
                            showTextReplyMessage()
                                .frame(maxWidth: .infinity, alignment: message.isNotMe ? .leading : .trailing)
                        }
                        
                        if isShowNameSender && message.isNotMe && (message.type != .admin(.channelCreation)) {
                            showSenderNameText()
                        }
                        
                        if message.uidMessageReply != nil {
                            BubbleReplyMessage(messageReply: message.messageReply ?? MessageItem.stubMessageText, messageCurrent: message)
                                .offset(y: 10)
                                .zIndex(-1)
                        }
                        composeDynamicBubbleView()
                            .scaleEffect(x: isScaled ? 1.01 : 1.0 ,y: isScaled ? 1.05 : 1.0)  // Apply scale effect based on state
                            .animation(.easeInOut(duration: 0.25), value: isScaled)  // 1s animation
                            .onAppear {
                                if viewModel.bubbleMessageDidSelect?.messageReply?.id == message.id {
                                    scaleUpAndReset()  // Trigger the animation
                                }
                            }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .onChange(of: viewModel.bubbleMessageDidSelect) { oldSelectedMessage,newSelectedMessage in
            if newSelectedMessage?.messageReply?.id == message.id {
                scaleUpAndReset()  // Trigger the animation when a new message is selected
            }
        }
        .padding(.horizontal, -8)
    }
    
    @ViewBuilder
    private func composeDynamicBubbleView() -> some View {
        switch message.type {
        case .text:
            BubbleTextView(
                message: message,
                isShowAvatarSender: isShowAvatarSender
            ) { state, message in
                handleAction(state, message)
            }
        case .photo,.video:
            BubbleImageView(
                message: message,  
                isShowAvatarSender: isShowAvatarSender
            ) { state, message in
                handleAction(state, message)
            }
        case .admin(let adminType):
            switch adminType {
            case .channelCreation:
                if channel.isGroupChat {
                    AdminBubbleTextView(channel: channel)
                }
            }
        case .audio:
            BubbleAudioView(
                message: message,
                isShowAvatarSender: isShowAvatarSender
            ) { state, message in
                handleAction(state, message)
            }
        case .videoCall:
            BubbleVideoCallView(
                message: message,
                isShowAvatarSender: isShowAvatarSender
            )
        case .sticker:
            BubbleStickerView(
                message: message,
                isShowAvatarSender: isShowAvatarSender
            ) { state, message in
                handleAction(state, message)
            }
        case .emoji:
            BubbleEmojiView(
                message: message,
                isShowAvatarSender: isShowAvatarSender
            ) { state, message in
                handleAction(state, message)
            }
        case .location:
            BubbleLocationView(
                message: message,
                isShowAvatarSender: isShowAvatarSender)
            { state, message in
                handleAction(state, message)
            }
        case .replyStory:
            BubbleStoryReplyView(
                message: message,
                isShowAvatarSender: isShowAvatarSender)
            { state, message in
                handleAction(state, message)
            }
        case .replyNote:
            BubbleNoteReplyView(
                message: message,
                isShowAvatarSender: isShowAvatarSender)
            { state, message in
                handleAction(state, message)
            }
        case .fileMedia:
            BubbleFileView(
                message: message,
                isShowAvatarSender: isShowAvatarSender)
            { state, message in
                handleAction(state, message)
            }
        }
    }
    
    /// Function to scale up and reset the scale back after 1s
        private func scaleUpAndReset() {
            // Scale up
            withAnimation {
                isScaled = true
            }
            
            // After 1 second, reset the scale back to normal
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    isScaled = false
                    viewModel.bubbleMessageDidSelect = nil
                }
            }
        }
    
    /// Show Text Reply story
    private func showTextReplyNote() -> some View {
        HStack(spacing: 0) {
            if message.type == .replyNote && message.isNotMe {
                VStack {
                    
                }
                .frame(width: 40)
                HStack {
                    Image(systemName: "arrowshape.turn.up.left.fill")
                    Text("\(channel.usersChannel[0].username) replied you note")
                }
                .font(.footnote)
                .foregroundStyle(Color(.systemGray))
                .padding(.leading, 5)
            } else if message.type == .replyNote && !message.isNotMe {
                HStack {
                    Image(systemName: "arrowshape.turn.up.left.fill")
                    Text("You replied to their note")
                }
                .font(.footnote)
                .foregroundStyle(Color(.systemGray))
            }
        }
    }
    
    /// Show Text Reply story
    private func showTextReplyStory() -> some View {
        HStack(spacing: 0) {
            if message.type == .replyStory && message.isNotMe {
                VStack {
                    
                }
                .frame(width: 40)
                HStack {
                    Image(systemName: "arrowshape.turn.up.left.fill")
                    Text("\(channel.usersChannel[0].username) replied you story")
                }
                .font(.footnote)
                .foregroundStyle(Color(.systemGray))
                .padding(.leading, 5)
            } else if message.type == .replyStory && !message.isNotMe {
                HStack {
                    Image(systemName: "arrowshape.turn.up.left.fill")
                    Text("You replied to \(channel.usersChannel[0].username)'s story")
                }
                .font(.footnote)
                .foregroundStyle(Color(.systemGray))
            }
        }
    }
    
    /// Show Text Reply message
    private func showTextReplyMessage() -> some View {
        HStack(spacing: 0) {
            if message.uidMessageReply != nil && message.messageReply?.isNotMe ?? false && !message.isNotMe {
                if let senderReply = message.messageReply?.sender?.username {
                    HStack {
                        Image(systemName: "arrowshape.turn.up.left.fill")
                        Text("You replied to \(senderReply)'s message")
                    }
                    .font(.footnote)
                    .foregroundStyle(Color(.systemGray))
                }
            } else if message.uidMessageReply != nil && message.messageReply?.isNotMe ?? false && message.isNotMe {
                VStack {
                    
                }
                .frame(width: 40)
                if let senderReply = message.messageReply?.sender?.username {
                    HStack {
                        Image(systemName: "arrowshape.turn.up.left.fill")
                        Text("\(message.sender?.username ?? "Unknown") replied to \(senderReply)'s message")
                    }
                    .font(.footnote)
                    .foregroundStyle(Color(.systemGray))
                    .padding(.leading, 7)
                }
            } else if message.uidMessageReply != nil && !(message.messageReply?.isNotMe ?? false) && !message.isNotMe {
                HStack {
                    Image(systemName: "arrowshape.turn.up.left.fill")
                    Text("You replied to yourself")
                }
                .font(.footnote)
                .foregroundStyle(Color(.systemGray))
            } else if message.uidMessageReply != nil && !(message.messageReply?.isNotMe ?? false) && message.isNotMe {
                VStack {
                    
                }
                .frame(width: 40)
                HStack {
                    Image(systemName: "arrowshape.turn.up.left.fill")
                    Text("\(message.sender?.username ?? "Unknown") replied to your message")
                }
                .font(.footnote)
                .foregroundStyle(Color(.systemGray))
                .padding(.leading, 7)
            }
        }
    }
    
    /// Show Sender
    private func showSenderNameText() -> some View {
        Text(message.sender?.username ?? "Unknown")
            .lineLimit(1)
            .foregroundStyle(.gray)
            .font(.footnote)
            .padding(.bottom, 2)
            .padding(.horizontal, 20)
            .padding(.leading, 30)
    }
    
    /// Show new day
    private func showNewDay() -> some View {
        Text(message.timeStamp.relativeDateString.uppercased())
            .lineLimit(1)
            .foregroundStyle(Color(.systemGray))
            .font(.footnote)
            .padding(.bottom, 3)
            .padding(.vertical, 10)
    }
}
//
//#Preview {
//    BubbleView(message: .stubMessageReplyNote, channel: .placeholder, isNewDay: false, isShowNameSender: false, isShowAvatarSender: false) { state, message in
//        
//    }
//}
