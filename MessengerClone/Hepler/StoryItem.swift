//
//  StoryItem.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 30/9/24.
//

import Foundation
import SwiftUI

struct GroupStoryItem: Identifiable, Hashable {
    let id: String
    let owner: UserItem
    let stories: [StoryItem]
    
    static let dummyGroupStory: GroupStoryItem = GroupStoryItem(id: UUID().uuidString, owner: UserItem(uid: UUID().uuidString, username: "", email: ""), stories: [])
}

struct StoryItem: Hashable {
    let id: String
    let storyImageURL: String
    let ownerUid: String
    let timeStamp: Date
    let type: StoryType
    
    static let dummyStory: StoryItem = StoryItem(id: UUID().uuidString, storyImageURL: "", ownerUid: "", timeStamp: Date(), type: .image)
}

extension StoryItem {
    init?(dict: [String:Any]) {
        self.id = dict[.id] as? String ?? ""
        self.storyImageURL = dict[.storyImageURL] as? String ?? ""
        self.ownerUid = dict[.ownerUid] as? String ?? ""
        let timeStamp = dict[.timeStamp] as? TimeInterval ?? 0
        self.timeStamp = Date(timeIntervalSince1970: timeStamp)
        let type = dict[.type] as? String ?? "image"
        self.type = StoryType(type) ?? .image
    }
}

enum StoryType {
    case image, video
    
    var title: String {
        switch self {
        case .image:
            return "image"
        case .video:
            return "video"
        }
    }
    
    init?(_ stringValue: String) {
        switch stringValue {
        case "image":
            self = .image
        case "video":
            self = .video
        default:
            self = .image
        }
    }
}

extension String {
    static let storyImageURL = "storyImageURL"
}
