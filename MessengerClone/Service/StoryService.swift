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
    
//    /// Fetch All Story
//    static func fetchStories(completion: @escaping ([GroupStoryItem]) -> Void) {
//        
//        FirebaseConstants.UserStoryRef.observeSingleEvent(of: .value) { snapshot in
//            guard let data = snapshot.value as? [String: [String:Any]] else {
//                completion([])
//                return
//            }
//            
//            var listGroupStory = [GroupStoryItem]()
//            
//            for (ownerUid, storyData) in data {
//                UserService.fetchUserByUid(ownerUid) { userItem in
//                    guard let userItem else { return }
//                    
//                    var groupCell = [StoryItem]()
//                    
//                    for (_ , storyDict) in storyData {
//                        guard let storyDict = storyDict as? [String:Any] else { return }
//                        
//                        guard let storyItem = StoryItem(dict: storyDict) else { return }
//                        groupCell.append(storyItem)
//                    }
//                    
//                    let groupStory = GroupStoryItem(id: ownerUid, owner: userItem, stories: groupCell)
//                    listGroupStory.append(groupStory)
//                }
//            }
//            
//            completion(listGroupStory)
//        }
//    }
    
    /// Fetch All Story
    static func fetchStories(completion: @escaping ([GroupStoryItem]) -> Void) {

        FirebaseConstants.UserStoryRef.observeSingleEvent(of: .value) { snapshot in
            guard let data = snapshot.value as? [String: [String:Any]] else {
                completion([])
                return
            }

            var listGroupStory = [GroupStoryItem]()
            let group = DispatchGroup()  // Use DispatchGroup to manage async calls

            for (ownerUid, storyData) in data {
                group.enter()  // Enter the dispatch group for each ownerUid

                UserService.fetchUserByUid(ownerUid) { userItem in
                    guard let userItem else {
                        group.leave()  // Leave the group if user fetch fails
                        return
                    }

                    var groupCell = [StoryItem]()

                    for (_, storyDict) in storyData {
                        guard let storyDict = storyDict as? [String:Any] else {
                            continue
                        }

                        // Create StoryItem and append to groupCell
                        guard let storyItem = StoryItem(dict: storyDict) else { continue }
                        groupCell.append(storyItem)
                    }

                    // Create GroupStoryItem and append to list
                    let groupStory = GroupStoryItem(id: ownerUid, owner: userItem, stories: groupCell)
                    listGroupStory.append(groupStory)

                    group.leave()  // Leave the dispatch group after processing this user
                }
            }

            // Notify when all the async calls are finished
            group.notify(queue: .main) {
                completion(listGroupStory)
            }
        }
    }
}

