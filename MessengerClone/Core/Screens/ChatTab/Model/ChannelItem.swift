//
//  ChannelItem.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 14/8/24.
//

import Foundation
import FirebaseAuth

struct ChannelItem: Identifiable, Hashable {
    var id: String
    var name: String?
    private var lastMessage: String
    var creationDate: Date
    var lastMessageTimestamp: Date
    var membersCount: Int
    var adminUids: [String]
    var memberUids: [String]
    var members: [UserItem]
    var createdBy: String
    let lastMessageType: MessageType
    private var thumbnailUrl: String?
    
    /// Is Group Chat
    var isGroupChat: Bool {
        return membersCount > 2
    }
    
    /// Get users not including me of channel
    var usersChannel: [UserItem] {
        guard let currentUid = Auth.auth().currentUser?.uid else { return [] }
        return members.filter{ $0.uid != currentUid }
    }
    
    /// Name Channel
    var title: String {
        if let name = name {
            return name
        }
        
        if isGroupChat {
            return groupName
        } else {
            return usersChannel.first?.username ?? "UnknownUser"
        }
    }
    
    /// Preview message `channel`
    var previewMessage: String {
        switch lastMessageType {
        case .admin:
            return "Newly created chat!"
        case .text:
            return lastMessage
        case .photo:
            return "Photo"
        case .video:
            return "Video"
        case .audio:
            return "Audio"
        case .videoCall:
            return "Video Call"
        case .sticker:
            return "Sticker"
        case .emoji:
            return "Like emoji"
        case .location:
            return "Shared location"
        case .replyStory:
            return "Reply story"
        case .replyNote:
            return "Reply note"
        case .fileMedia:
            return "File Media"
        }
    }
    
    /// Get name of Group Channel
    private var groupName: String {
        let memberCountsNotIncludingMe = membersCount - 1
        let nameOfUsers = usersChannel.compactMap{ $0.username }
        
        if memberCountsNotIncludingMe == 2 {
            return nameOfUsers.joined(separator: " and ")
        } else if memberCountsNotIncludingMe > 2 {
            let membersCountOther = memberCountsNotIncludingMe - 2
            return nameOfUsers.prefix(2).joined(separator: ", ") + " and \(membersCountOther) others"
        }
        
        return "Unknown"
    }
    
    /// Check channel was created by me or not
    var createdByMe: Bool {
        return createdBy == Auth.auth().currentUser?.uid ?? ""
    }
    
    /// Get username of creator
    var creatorName: String {
        return members.first{ $0.uid == createdBy }?.username ?? "Someone"
    }
    
    /// Cover image
    var coverImageUrl: String? {
        if let thumbnailUrl = thumbnailUrl {
            return thumbnailUrl
        }
        
        if isGroupChat == false {
            return usersChannel.first?.profileImage
        }
        
        return nil
    }
    
    /// Array ImageUrl of Group (2 url profile)
    var listImageForThumbnail: [String?] {
        if !isGroupChat {
            return []
        }
        var arrayUrl = [String?]()
        
        for i in 0...1 {
            let profileUrl = usersChannel[i].profileImage
            arrayUrl.append(profileUrl)
        }
        return arrayUrl
    }
    
    static let placeholder: ChannelItem = ChannelItem.init(id: "1", lastMessage: "None", creationDate: Date(), lastMessageTimestamp: Date(), membersCount: 4, adminUids: [], memberUids: [], members: [], createdBy: "1234", lastMessageType: .text)
    
    static let placeholders: [ChannelItem] = [
        ChannelItem.init(id: "1", lastMessage: "None", creationDate: Date(), lastMessageTimestamp: Date(), membersCount: 2, adminUids: [], memberUids: [], members: [], createdBy: "1234", lastMessageType: .text),
        ChannelItem.init(id: "2", lastMessage: "None", creationDate: Date(), lastMessageTimestamp: Date(), membersCount: 2, adminUids: [], memberUids: [], members: [], createdBy: "5123", lastMessageType: .text)
    ]
}

extension ChannelItem {
    init(_ channelDict: [String: Any]) {
        self.id = channelDict[.id] as? String ?? ""
        self.name = channelDict[.name] as? String ?? nil
        self.lastMessage = channelDict[.lastMessage] as? String ?? ""
        let creationInterval = channelDict[.creationDate] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: creationInterval)
        let lastMsgTimeStampInterval = channelDict[.lastMessageTimestamp] as? Double ?? 0
        self.lastMessageTimestamp = Date(timeIntervalSince1970: lastMsgTimeStampInterval)
        self.membersCount = channelDict[.membersCount] as? Int ?? 0
        self.adminUids = channelDict[.adminUids] as? [String] ?? []
        self.memberUids = channelDict[.memberUids] as? [String] ?? []
        self.members = channelDict[.members] as? [UserItem] ?? []
        self.createdBy = channelDict[.createdBy] as? String ?? ""
        let messageType = channelDict[.lastMessageType] as? String ?? "text"
        self.lastMessageType = MessageType(messageType) ?? .text
    }
}

extension String {
    static let id = "id"
    static let name = "name"
    static let creationDate = "creationDate"
    static let lastMessageTimestamp = "lastMessageTimestamp"
    static let membersCount = "membersCount"
    static let adminUids = "adminUids"
    static let members = "members"
    static let createdBy = "createdBy"
    static let memberUids = "memberUids"
    static let lastMessageType = "lastMessageType"
    static let lastMessage = "lastMessage"
    static let thumbnailUrl = "thumbnailUrl"
}
