//
//  ChatScreen.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 24/7/24.
//

import SwiftUI

struct ChatScreen: View {
    
    var body: some View {
        VStack(spacing: 0){
            List {
                Section {
                    ListStoryView()
                    ListChannelView()
                }
                .listRowInsets(EdgeInsets())
                .padding(.horizontal, 10)
            }
            .listStyle(.plain)
        }
    }
}


#Preview {
    ChatScreen()
}
