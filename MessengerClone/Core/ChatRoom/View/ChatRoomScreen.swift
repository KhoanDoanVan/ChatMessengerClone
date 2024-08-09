//
//  ChatRoomScreen.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 8/8/24.
//

import SwiftUI

struct ChatRoomScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text: String = ""
    
    var body: some View {
        MessageListView()
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden()
        .toolbar {
            buttonBack()
            buttonCall()
            buttonVideo()
            headerChatRoom()
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                Divider()
                TextInputArea()
                    .padding(.top, 5)
            }
        }
    }
    
    
}

extension ChatRoomScreen {
    @ToolbarContentBuilder
    private func buttonBack() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .bold()
            }
        }
    }
    
    @ToolbarContentBuilder
    private func buttonCall() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                
            } label: {
                Image(systemName: "phone.fill")
                    .bold()
            }
        }
    }
    
    @ToolbarContentBuilder
    private func buttonVideo() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                
            } label: {
                Image(systemName: "video.fill")
                    .bold()
            }
        }
    }
    
    @ToolbarContentBuilder
    private func headerChatRoom() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            NavigationLink {
                ConfigChatView()
            } label: {
                HStack {
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.messagesBlack)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("User name")
                            .fontWeight(.bold)
                            .foregroundStyle(.messagesBlack)
                        Text("Active now")
                            .font(.footnote)
                            .foregroundStyle(Color(.systemGray))
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatRoomScreen()
    }
}
