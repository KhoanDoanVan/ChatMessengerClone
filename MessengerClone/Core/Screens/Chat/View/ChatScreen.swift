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
                        .listRowSeparator(.hidden)
                        .padding(.top)
                    ListChannelView()
                        .listRowSeparator(.hidden)
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
