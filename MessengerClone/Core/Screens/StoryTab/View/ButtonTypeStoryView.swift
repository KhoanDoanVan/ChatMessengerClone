//
//  ButtonTypeStoryView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 5/8/24.
//

import SwiftUI

struct ButtonTypeStoryView: View {
    
    let storyType: StoryType
    
    init(_ storyType: StoryType) {
        self.storyType = storyType
    }
    
    private var widthOfStory: CGFloat {
        return ((UIWindowScene.current?.screenWidth ?? 0) / 2) - 20
    }
    
    var body: some View {
        Rectangle()
            .frame(width: widthOfStory, height: 140)
            .cornerRadius(25)
            .overlay {
                VStack(spacing: 10) {
                    Image(systemName: storyType.icon)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(storyType.title)
                }
                .foregroundStyle(.messagesBlack)
            }
            .foregroundStyle(.messagesGray)
    }
}

#Preview {
    ButtonTypeStoryView(.camera)
}
