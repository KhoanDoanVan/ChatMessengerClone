//
//  ListChannelView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 24/7/24.
//

import SwiftUI

struct ListChannelView: View {
    
    let channels: [ChannelItem]
    
    var body: some View {
        ForEach(channels) { channel in
            NavigationLink(destination: ChatRoomScreen(channel: channel)) {
                ChannelItemView(channel: channel)
            }
            .buttonStyle(PlainButtonStyle())
            .listRowSeparator(.hidden)
            .padding(.vertical, 10)
        }
        .listRowInsets(EdgeInsets())
        .padding(.horizontal, 10)
    }
}

#Preview {
    ListChannelView(channels: [])
}
