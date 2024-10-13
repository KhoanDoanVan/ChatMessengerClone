//
//  MessageItem.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 11/8/24.
//

import Foundation
import FirebaseAuth
import SwiftUI
import MapKit

// MARK: Message Item
struct MessageItem {
    let id: String
    let text: String
    let type: MessageType
    let timeStamp: Date
    let ownerUid: String
    var sender: UserItem?
    let thumbnailUrl: String?
    var thumbnailHeight: CGFloat?
    var thumbnailWidth: CGFloat?
    var videoURL: String?
    var videoDuration: TimeInterval?
    var audioURL: String?
    var audioDuration: TimeInterval?
    var audioLevels: [Float]?
    var emojis: [ReactionItem]?
    var videoCallDuration: TimeInterval?
    var urlSticker: String?
    var emojiString: String?
    var location: LocationItem?
    var urlImageStory: String?
    var textNote: String?
    
    /// Show avatar or not
    var isNotMe: Bool {
        return direction == .received
    }
    
    /// Contain same owner
    func containSameOwner(as message: MessageItem) -> Bool {
        if let userA = message.sender,
           let userB = self.sender
        {
            return userA == userB
        } else {
            return false
        }
    }
    
    // MARK: Alignment Message
    var direction: MessageDirection {
        return ownerUid == Auth.auth().currentUser?.uid ? .sent : .received
    }
    
    var alignment: Alignment {
        return direction == .received ? .leading : .trailing
    }
    
    private let horizontalPadding: CGFloat = 25
    
    var leadingPadding: CGFloat {
        return direction == .received ? 0 : horizontalPadding
    }
    
    var trailingPadding: CGFloat {
        return direction == .received ? horizontalPadding : 0
    }
    
    // MARK: Resize Image Message
    var imageWidth: CGFloat {
        return (UIWindowScene.current?.screenWidth ?? 0) / 1.75 // return 2/3 width screen
    }
    
    /// Resize image properly for sceen
    var imageSize: CGSize {
        let photoWidth = thumbnailWidth ?? 0
        let photoHeight = thumbnailHeight ?? 0
        let imageHeight = CGFloat(photoHeight / photoWidth * imageWidth)
        return CGSize(width: imageWidth, height: imageHeight)
    }
    
    // MARK: Duration
    var durationVideoString: String {
        return videoDuration?.formatElaspedTime ?? "00:00"
    }
    
    var durationAudioString: String {
        return audioDuration?.formatElaspedTime ?? "00:00"
    }
    
    // MARK: Stub message
    static let stubMessageText: MessageItem = MessageItem(id: UUID().uuidString, text: "Hahaha", type: .text, timeStamp: Date(), ownerUid: UUID().uuidString, thumbnailUrl: nil)
    static let stubMessageTextIsMe: MessageItem = MessageItem(id: UUID().uuidString, text: "Hahaha", type: .text, timeStamp: Date(), ownerUid: "11", thumbnailUrl: nil)
    static let stubMessageImage: MessageItem = MessageItem(id: UUID().uuidString, text: "e", type: .photo, timeStamp: Date(), ownerUid: UUID().uuidString, thumbnailUrl: nil)
    static let stubMessageAudio: MessageItem = MessageItem(id: UUID().uuidString, text: "", type: .audio, timeStamp: Date(), ownerUid: UUID().uuidString, thumbnailUrl: nil)
    static let stubMessageReplyStory: MessageItem = MessageItem(id: UUID().uuidString, text: "This is", type: .replyStory, timeStamp: Date(), ownerUid: "", thumbnailUrl: nil, urlImageStory: "https://plus.unsplash.com/premium_photo-1671656349322-41de944d259b?q=80&w=1587&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D")
    static let stubMessageReplyNote: MessageItem = MessageItem(id: UUID().uuidString, text: "Beauti", type: .replyNote, timeStamp: Date(), ownerUid: "", thumbnailUrl: nil, textNote: "This is the first note i don't think it's true")
    
    static let stubMessages: [MessageItem] = [
        MessageItem(id: UUID().uuidString, text: "Hi", type: .text, timeStamp: Date(), ownerUid: UUID().uuidString, thumbnailUrl: nil),
        MessageItem(id: UUID().uuidString, text: "", type: .photo, timeStamp: Date(), ownerUid: UUID().uuidString, thumbnailUrl: nil),
        MessageItem(id: UUID().uuidString, text: "Nice try", type: .text, timeStamp: Date(), ownerUid: UUID().uuidString, thumbnailUrl: nil),
    ]
}

// MARK: Reaction Item
struct ReactionItem: Hashable {
    let ownerUid: String
    let reaction: String
    var id: String?
    var senderReaction: UserItem?
}

// MARK: Location Item
struct LocationItem: Hashable {
    let latitude: CLLocationDegrees
    let longtitude: CLLocationDegrees
    let nameAddress: String
}

extension MessageItem {
    init(id: String, dict: [String:Any]) {
        self.id = id
        self.text = dict[.text] as? String ?? ""
        let type = dict[.type] as? String ?? "text"
        self.type = MessageType(type) ?? .text
        let timeInterval = dict[.timeStamp] as? TimeInterval ?? 0
        self.timeStamp = Date(timeIntervalSince1970: timeInterval)
        self.ownerUid = dict[.ownerUid] as? String ?? ""
        self.thumbnailUrl = dict[.thumbnailUrl] as? String ?? nil
        self.thumbnailWidth = dict[.thumbnailWidth] as? CGFloat ?? nil
        self.thumbnailHeight = dict[.thumbnailHeight] as? CGFloat ?? nil
        self.videoURL = dict[.videoURL] as? String ?? nil
        self.videoDuration = dict[.videoDuration] as? TimeInterval ?? nil
        self.audioURL = dict[.audioURL] as? String ?? nil
        self.audioDuration = dict[.audioDuration] as? TimeInterval ?? nil
        self.videoCallDuration = dict[.videoCallDuration] as? TimeInterval ?? nil
        self.urlSticker = dict[.urlSticker] as? String ?? ""
        self.emojiString = dict[.emojiString] as? String ?? ""
        self.urlImageStory = dict[.urlImageStory] as? String ?? ""
        self.textNote = dict[.textNote] as? String ?? ""
        
        /// Extract audio levels
        if let audioLevelsArray = dict[.audioLevels] as? [NSNumber] {
            self.audioLevels = audioLevelsArray.map{ $0.floatValue }
        } else {
            self.audioLevels = nil
        }
        
        /// Extract emojis
        if let emojiArray = dict[.emojis] as? [[String:Any]] {
            self.emojis = emojiArray.map{ ReactionItem(dict: $0)}
        } else {
            self.emojis = nil
        }
        
        /// Extract location
        if let locationDict = dict[.location] as? [String:Any],
           let latitude = locationDict[.latitude] as? CLLocationDegrees,
           let longtitude = locationDict[.longtitude] as? CLLocationDegrees,
           let nameAddress = locationDict[.nameAddress] as? String
        {
            self.location = LocationItem(latitude: latitude, longtitude: longtitude, nameAddress: nameAddress)
        } else {
            self.location = nil
        }
    }
}

extension ReactionItem {
    init(dict: [String:Any]) {
        self.ownerUid = dict[.ownerUid] as? String ?? ""
        self.reaction = dict[.reaction] as? String ?? ""
    }
    
    /// Convert to array when upload to db
    var asDictionary: [String:Any] {
        return [
            "ownerUid": ownerUid,
            "reaction": reaction
        ]
    }
    
}

extension String {
    static let type = "type"
    static let timeStamp = "timeStamp"
    static let ownerUid = "ownerUid"
    static let text = "text"
    static let thumbnailWidth = "thumbnailWidth"
    static let thumbnailHeight = "thumbnailHeight"
    static let videoURL = "videoURL"
    static let videoDuration = "videoDuration"
    static let audioURL = "audioURL"
    static let audioDuration = "audioDuration"
    static let audioLevels = "audioLevels"
    static let emojis = "emojis"
    static let reaction = "reaction"
    static let videoCallDuration = "videoCallDuration"
    static let urlSticker = "urlSticker"
    static let emojiString = "emojiString"
    static let location = "location"
    static let latitude = "latitude"
    static let longtitude = "longtitude"
    static let nameAddress = "nameAddress"
    static let urlImageStory = "urlImageStory"
}
