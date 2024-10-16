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
    
    let handleAction: (_ state: Bool, _ message: MessageItem) -> Void
    
    var body: some View {
        VStack {
            if isNewDay {
                showNewDay()
            }
            
            
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
                VStack(alignment: .leading, spacing: 0) {
                    
                    if message.uidMessageReply != nil {
                        showTextReplyMessage()
                            .frame(maxWidth: .infinity, alignment: message.isNotMe ? .leading : .trailing)
                    }
                    
                    if isShowNameSender && message.isNotMe && (message.type != .admin(.channelCreation)) {
                        showSenderNameText()
                    }
                    
                    ZStack {
                        if message.uidMessageReply != nil {
                            BubbleReplyMessage(message: message)
                        }
                        composeDynamicBubbleView()
                    }
                }
                .frame(maxWidth: .infinity)
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
    
    /// Show Text Reply story
    private func showTextReplyNote() -> some View {
        HStack(spacing: 0) {
            if message.type == .replyNote && message.isNotMe {
                VStack {
                    
                }
                .frame(width: 40, height: 40)
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
                .frame(width: 40, height: 40)
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
            if message.uidMessageReply != nil && message.isNotMe {
                VStack {
                    
                }
                .frame(width: 40, height: 40)
                HStack {
                    Image(systemName: "arrowshape.turn.up.left.fill")
                    Text("\(message.sender?.username ?? "Unknown") replied to yourself")
                }
                .font(.footnote)
                .foregroundStyle(Color(.systemGray))
                .padding(.leading, 5)
            } else if message.uidMessageReply != nil && !message.isNotMe {
                HStack {
                    Image(systemName: "arrowshape.turn.up.left.fill")
                    Text("You replied to \(message.sender?.username ?? "Unknown")'s message")
                }
                .font(.footnote)
                .foregroundStyle(Color(.systemGray))
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

#Preview {
    BubbleView(message: .stubMessageReplyNote, channel: .placeholder, isNewDay: false, isShowNameSender: false, isShowAvatarSender: false) { state, message in
        
    }
}
