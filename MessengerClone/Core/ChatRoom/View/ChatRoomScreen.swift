//
//  ChatRoomScreen.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 8/8/24.
//

import SwiftUI

struct ChatRoomScreen: View {
    var body: some View {
        VStack {
            
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            buttonBack()
            buttonCall()
            buttonVideo()
            headerChatRoom()
        }
    }
}

extension ChatRoomScreen {
    @ToolbarContentBuilder
    private func buttonBack() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                
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
            Button {
                
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
