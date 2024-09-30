//
//  StoryService.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 30/9/24.
//

import Foundation
import FirebaseAuth

struct StoryService {
    
    /// Create new story
    static func createNewStory(_ url: URL, completion: @escaping () -> Void ) {
        
        guard let storyId = FirebaseConstants.UserStoryRef.childByAutoId().key,
              let currentUid = Auth.auth().currentUser?.uid
        else {
            return
        }
        
        let timeStamp = Date().timeIntervalSince1970
        
        let storyDict: [String:Any] = [
            .id: storyId,
            .storyImageURL: url.absoluteString,
            .ownerUid: currentUid,
            .timeStamp: timeStamp,
            .type: StoryType.image.title
        ]
        
        FirebaseConstants.UserStoryRef.child(currentUid).child(storyId).setValue(storyDict)
        
        completion()
    }
}

