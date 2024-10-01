//
//  StoryViewModel.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 1/10/24.
//

import Foundation
import FirebaseAuth

class StoryViewModel: ObservableObject {
    @Published var listGroupStory: [GroupStoryItem] = []
    @Published var userCurrentUid: String?
    
    init() {
        StoryService.fetchStories { list in
            self.listGroupStory = list
            print("List Group Item: \(list)")
        }
        self.userCurrentUid = Auth.auth().currentUser?.uid
    }
    
    /// Check wheather this group from current user or not
    func checkOwner(_ uid: String) -> Bool {
        return uid != userCurrentUid
    }
}
