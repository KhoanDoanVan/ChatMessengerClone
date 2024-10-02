//
//  StoryCellView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 5/8/24.
//

import SwiftUI
import Kingfisher

struct StoryCellView: View {
    
    let groupStory: GroupStoryItem
    let isShowStory: Bool
    
    private var widthOfStory: CGFloat {
        return ((UIWindowScene.current?.screenWidth ?? 0) / 2) - 10
    }
    
    var body: some View {
        storyBoard()
    }
    
    
    @ViewBuilder
    private func storyBoard() -> some View {
        KFImage(URL(string: groupStory.stories[0].storyImageURL))
            .resizable()
            .scaledToFill()
            .frame(width: widthOfStory, height: 250)
            .cornerRadius(20)
            .overlay(alignment: .topLeading) {
                KFImage(URL(string: groupStory.owner.profileImage ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .padding([.top, .horizontal], 10)
            }
            .overlay(alignment: .bottomLeading) {
                Text(isShowStory ? (groupStory.owner.username) : "Your Story")
                    .foregroundStyle(.white)
                    .padding([.bottom, .horizontal], 10)
            }
            .foregroundStyle(.messagesWhite)
    }
}

//#Preview {
//    StoryCellView(story: ., isShowStory: false, owner: .placeholder) {
//        
//    }
//}
