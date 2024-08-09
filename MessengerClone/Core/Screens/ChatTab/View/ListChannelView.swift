//
//  ListChannelView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 24/7/24.
//

import SwiftUI

struct ListChannelView: View {
    var body: some View {
        ForEach(0..<12) { nav in
            NavigationLink(destination: ChatRoomScreen()) {
                ChannelItem()
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
    ListChannelView()
}
