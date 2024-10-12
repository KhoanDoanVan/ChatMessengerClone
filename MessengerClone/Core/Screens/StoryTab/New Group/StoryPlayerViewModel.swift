//
//  StoryPlayerViewModel.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 2/10/24.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth

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
    
    
    /// Send story reply
    func sendStoryReply() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        print("Inside sendStoryReply")
        
        getChannelFromCurrentAndOwnerStory(currentUid, storyCurrent.ownerUid) { channelId in
            print("ChannelId: \(channelId)")
            if let channelId {
                MessageService.sendStoryReply(to: channelId, from: currentUid, text: self.text, urlImageStory: self.storyCurrent.storyImageURL) {
                    self.isTyping = false
                    self.text = ""
                    print("Reply story to channel \(channelId) successfully.")
                }
            }
        }
    }
    
    /// Get channel from userCurrent and owner Story
    private func getChannelFromCurrentAndOwnerStory(_ currentUid: String, _ ownerStoryUid: String, completion: @escaping (String?) -> Void) {

        FirebaseConstants.ChannelRef
            .observeSingleEvent(of: .value) { snapshot in
                
                for case let channel as DataSnapshot in snapshot.children {
                                        
                    if let channelDict = channel.value as? [String: Any],
                       let membersCount = channelDict["membersCount"] as? Int,
                       membersCount == 2,
                       let membersArray = channelDict["memberUids"] as? [String],
                       membersArray.contains(currentUid) && membersArray.contains(ownerStoryUid) {

                        let channelId = channelDict["id"] as? String
                        completion(channelId)
                        print("ChannelId from current && ownerStory: \(channelId ?? "No channelId found")")
                        return
                    }
                }
                
                completion(nil)
            }
    }
}
