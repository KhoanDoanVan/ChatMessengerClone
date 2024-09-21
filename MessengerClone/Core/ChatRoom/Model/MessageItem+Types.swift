//
//  MessageItem+Types.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 9/8/24.
//

import Foundation

enum MessageType: Hashable {
    case admin(_ type: AdminMessageType),text, photo, video, audio, videoCall, sticker, emoji
    
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
        default:
            if let adminMessageType = AdminMessageType(rawValue: stringValue) {
                self = .admin(adminMessageType)
            } else {
                return nil
            }
        }
    }
}

enum Reaction: Int {
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
