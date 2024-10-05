//
//  ChannelItem.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 24/7/24.
//

import SwiftUI

struct ChannelItemView: View {
    
    let channel: ChannelItem
    
    private var channelPreviewMessage: String {
        let maxChar = 30
        let trailingChars = channel.previewMessage.count > maxChar ? "..." : ""
        let title = String(channel.previewMessage.prefix(maxChar) + trailingChars)
        
        return title
    }
    
    private var channelTitlePreview: String {
        let maxChar = 30
        let trailingChars = channel.title.count > maxChar ? "..." : ""
        let title = String(channel.title.prefix(maxChar) + trailingChars)
        
        return title
    }
    
    var body: some View {
        HStack {
            imageChannel(true)
            
            VStack(alignment: .leading) {
                Text(channelTitlePreview)
                    .foregroundStyle(.messagesBlack)
                    .fontWeight(.bold)
                HStack(spacing: 0){
                    Text(channelPreviewMessage)
                    Text(" • \(channel.lastMessageTimestamp.formattedTimeIntervalPreviewChannel())")
                }
                .foregroundStyle(.messagesBlack.opacity(0.5))
                .font(.subheadline)
            }
        }
    }
    
    @ViewBuilder
    private func imageChannel(_ isOnline: Bool) -> some View {
        ZStack {
            if channel.isGroupChat {
                CircularProfileImage(channel, size: .xMedium)
            } else {
                CircularProfileImage(channel.coverImageUrl ,size: .xMedium)
            }
            
            if isOnline && !channel.isGroupChat {
                onlineIcon()
            }
        }
        .frame(width: 75, height: 75)
    }
    
    @ViewBuilder
    private func onlineIcon() -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ZStack {
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.messagesWhite)
                    Circle()
                        .frame(width: 15, height: 15)
                        .foregroundStyle(.green)
                }
                .padding(3)
            }
        }
    }
}


#Preview {
    ChannelItemView(channel: .placeholder)
}
