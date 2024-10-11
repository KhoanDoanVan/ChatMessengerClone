//
//  StoryViewModel.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 1/10/24.
//

import Foundation
import FirebaseAuth

class StoryViewModel: ObservableObject {
    
    @Published var openCreateNewStory = false
    @Published var isOpenStoryPlayer = false
    
    @Published var listGroupStory: [GroupStoryItem] = []
    @Published var groupStoryCurrent: GroupStoryItem?
    @Published var userCurrentUid: String?
    
    @Published var groupStoryTapGesture: GroupStoryItem?
    
    init() {
        StoryService.removeAllStoriesOver24Hours {
            StoryService.fetchStories { list in
                self.listGroupStory = list
                /// Filter current group out of the list group story
                self.attachCurrentGroupStory()
                self.removeCurrentGroupStory()
            }
            self.userCurrentUid = Auth.auth().currentUser?.uid
        }
    }
    
    /// Check wheather this group from current user or not
    func checkOwner(_ uid: String) -> Bool {
        return uid != userCurrentUid
    }
    
    /// Filter current group story
    private func attachCurrentGroupStory() {
        for groupStory in self.listGroupStory {
            if groupStory.id == userCurrentUid {
                groupStoryCurrent = groupStory
            }
        }
    }
    
    /// Remove current group story out of the list group
    private func removeCurrentGroupStory() {
        guard let index = listGroupStory.firstIndex(where: { $0.id == userCurrentUid }) else { return }
        listGroupStory.remove(at: index)
    }
}
