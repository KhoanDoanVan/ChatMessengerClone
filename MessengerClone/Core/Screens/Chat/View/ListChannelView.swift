//
//  ListChannelView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 24/7/24.
//

import SwiftUI

struct ListChannelView: View {
    var body: some View {
        VStack {
            ForEach(0..<12) { _ in
                ChannelItem()
            }
        }
        .padding(.top, 20)
    }
}

#Preview {
    ListChannelView()
}
