//
//  StoryItemView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 24/7/24.
//

import SwiftUI

struct StoryItemView: View {
    
    var isStory: Bool
    var isOnline: Bool
    
    var body: some View {
        VStack {
            ZStack {
                if isStory {
                    borderBlueStory()
                }
                
                CircularProfileImage(size: .custom(isStory ? 75 : 85))
                
                if isOnline {
                    onlineIcon()
                }
            }
            Text("Username")
        }
        .padding(.leading, 10)
    }
    
    @ViewBuilder
    private func borderBlueStory() -> some View {
        Circle()
            .foregroundStyle(.blue)
            .frame(width: 85, height: 85)
        Circle()
            .foregroundStyle(.black)
            .frame(width: 80, height: 80)
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
    StoryItemView(isStory: false, isOnline: false)
}
