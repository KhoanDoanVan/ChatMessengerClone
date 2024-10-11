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
    
    /// Remove all story older 24 hours
    static func removeAllStoriesOver24Hours(completion: @escaping () -> Void) {
        let currentTime = Date().timeIntervalSince1970 //  seconds
        let twentyFourHoursInSeconds: Double = 24 * 60 * 60 // seconds
        
        FirebaseConstants.UserStoryRef
            .observeSingleEvent(of: .value) { snapshot in
                guard let data = snapshot.value as? [String: [String: Any]] else {
                    print("Failed to convert snapshot to data!")
                    return
                }
                
                let dispatchGroup = DispatchGroup()
                
                for (ownerUid, storyData) in data {
                    dispatchGroup.enter()
                    
                    for (storyId, storyDict) in storyData {
                        guard let storyDict = storyDict as? [String: Any],
                              let timeStamp = storyDict["timeStamp"] as? Double else {
                            continue
                        }
                        
                        if (currentTime - timeStamp) >= twentyFourHoursInSeconds {
                            FirebaseConstants.UserStoryRef
                                .child(ownerUid)
                                .child(storyId)
                                .removeValue { error, _ in
                                    if let error = error {
                                        print("Error removing story: \(error.localizedDescription)")
                                    } else {
                                        print("Successfully removed story.")
                                    }
                                    dispatchGroup.leave()
                                }
                        } else {
                            dispatchGroup.leave()
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    completion()
                }
            }
    }
}

