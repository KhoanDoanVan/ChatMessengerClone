//
//  MessageItem+Types.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 9/8/24.
//

import Foundation

enum MessageType: Hashable {
    case admin(_ type: AdminMessageType),
         text, photo,
         video, audio,
         videoCall, sticker,
         emoji, location,
         replyStory, replyNote,
         fileMedia
    
    var title: String {
        switch self {
        case .admin:
            return "admin"
        case .text:
            return "text"
        case .photo:
            return "photo"
        case .video:
            return "video"
        case .audio:
            return "audio"
        case .sticker:
            return "sticker"
        case .videoCall:
            return "videoCall"
        case .emoji:
            return "likeSticker"
        case .location:
            return "location"
        case .replyStory:
            return "replyStory"
        case .replyNote:
            return "replyNote"
        case .fileMedia:
            return "fileMedia"
        }
    }
    
    var nameOfType: String {
        switch self {
        case .admin:
            return "Admin"
        case .text:
            return "Text"
        case .photo:
            return "Photo"
        case .video:
            return "Video"
        case .audio:
            return "Audio"
        case .sticker:
            return "Sticker"
        case .videoCall:
            return "Video Call"
        case .emoji:
            return "Like Sticker"
        case .location:
            return "Location"
        case .replyStory:
            return "Reply Story"
        case .replyNote:
            return "Reply Note"
        case .fileMedia:
            return "Attachment"
        }
    }
    
    init?(_ stringValue: String) {
        switch stringValue {
        case "text":
            self = .text
        case "photo":
            self = .photo
        case "video":
            self = .video
        case "audio":
            self = .audio
        case "videoCall":
            self = .videoCall
        case "sticker":
            self = .sticker
        case "likeSticker":
            self = .emoji
        case "location":
            self = .location
        case "replyStory":
            self = .replyStory
        case "replyNote":
            self = .replyNote
        case "fileMedia":
            self = .fileMedia
        default:
            if let adminMessageType = AdminMessageType(rawValue: stringValue) {
                self = .admin(adminMessageType)
            } else {
                return nil
            }
        }
    }
}

enum Reaction: Int, CaseIterable {
    case like
    case heart
    case laugh
    case shocked
    case sad
    case pray
    
    var emoji: String {
        switch self {
        case .like:
            return "👍"
        case .heart:
            return "❤️"
        case .laugh:
            return "😂"
        case .shocked:
            return "😮"
        case .sad:
            return "😢"
        case .pray:
            return "🙏"
        }
    }
}

enum MessageDirection {
    case received, sent
}

enum AdminMessageType: String {
    case channelCreation
}

enum MessageReplyType: String {
    case textReply, imageReply, videoReply, stickerReply, audioReply, likeReply, attachmentReply
    
    init?(_ stringValue: String) {
        switch stringValue {
        case "textReply":
            self = .textReply
        case "imageReply":
            self = .imageReply
        case "videoReply":
            self = .videoReply
        case "stickerReply":
            self = .stickerReply
        case "audioReply":
            self = .audioReply
        case "likeReply":
            self = .likeReply
        case "attachmentReply":
            self = .attachmentReply
        default:
            return nil
        }
    }
}

enum MessageUnsentType: String {
    case everyOne, onlyMe
}
