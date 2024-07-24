//
//  ChannelItem.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 24/7/24.
//

import SwiftUI

struct ChannelItem: View {
    var body: some View {
        HStack {
            imageChannel(true)
            
            VStack(alignment: .leading) {
                Text("User name")
                    .foregroundStyle(.messagesBlack)
                    .fontWeight(.bold)
                Text("You: last message")
                    .foregroundStyle(.messagesBlack.opacity(0.5))
            }
        }
    }
    
    @ViewBuilder
    private func imageChannel(_ isOnline: Bool) -> some View {
        ZStack {
            Circle()
                .frame(width: 75, height: 75)
            
            if isOnline {
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
    ChannelItem()
}
