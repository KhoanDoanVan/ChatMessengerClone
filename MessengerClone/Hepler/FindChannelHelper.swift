//
//  FindChannelHelper.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 13/10/24.
//

import Foundation
import Firebase


/// Get channel from userCurrent and owner Story
func getChannelFromCurrentAndOwnerStory(_ currentUid: String, _ ownerStoryUid: String, completion: @escaping (String?) -> Void) {

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
