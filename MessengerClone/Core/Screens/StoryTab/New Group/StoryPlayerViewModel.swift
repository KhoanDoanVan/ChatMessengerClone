//
//  StoryPlayerViewModel.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 2/10/24.
//

import Foundation
import SwiftUI

class StoryPlayerViewModel: ObservableObject {
    
    @Published var currentGroupStory: GroupStoryItem
    @Published var text: String = ""
    @Published var isTyping: Bool = false
    
    @Published var storyCurrent: StoryItem
    @Published var widthOfTimeStory: CGFloat
    
    init(currentGroupStory: GroupStoryItem) {
        self.currentGroupStory = currentGroupStory
        self.storyCurrent = currentGroupStory.stories[0]
        
        // Break up the width calculation into simpler steps
        let screenWidth = UIWindowScene.current?.screenWidth ?? 0
        let storiesCount = CGFloat(currentGroupStory.stories.count)
        let spacing: CGFloat = 3.0
        let totalSpacing = spacing * (storiesCount - 1)
        let adjustedWidth = screenWidth - 30 - totalSpacing
        
        self.widthOfTimeStory = adjustedWidth / storiesCount
    }
}
