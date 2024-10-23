//
//  MessageService.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 18/8/24.
//

import Foundation
import Firebase

struct MessageService {
    
    /// Get message by channelId, messageId
    static func getMessage(_ channelId: String, _ messageId: String, completion: @escaping (MessageItem?) -> Void) {
        FirebaseConstants.MessageChannelRef.child(channelId).child(messageId)
            .observeSingleEvent(of: .value) { snapshot in
                guard let data = snapshot.value as? [String:Any] else {
                    completion(nil)
                    return
                }
        
                let messageItem = MessageItem(id: data["id"] as? String ?? "", dict: data)
                completion(messageItem)
            }
    }
    
    /// Get only first an message
    static func getFirstMessage(_ channel: ChannelItem, completion: @escaping(MessageItem) -> Void) {
        FirebaseConstants.MessageChannelRef.child(channel.id)
            .queryLimited(toFirst: 1)
            .observeSingleEvent(of: .value) { snapshot in
                guard let messagesDict = snapshot.value as? [String:Any] else { return } // array dict
                
                messagesDict.forEach { key, value in
                    guard let messageDict = snapshot.value as? [String:Any] else { return }
                    let firstMessage = MessageItem(id: key, dict: messageDict)
                    firstMessage.sender = channel.members.first(where: { $0.uid == firstMessage.ownerUid })
                    
                    if let messageReplyUid = firstMessage.uidMessageReply {
                        self.getMessage(channel.id, messageReplyUid) { messageItem in
                            if let messageItem {
                                firstMessage.messageReply = messageItem
                                firstMessage.messageReply?.sender = channel.members.first(where: { $0.uid == firstMessage.messageReply?.ownerUid })
                                completion(firstMessage)
                            }
                        }
                    }
                    
                    completion(firstMessage)
                }
            } withCancel: { failed in
                print("Failed to fetch first message: \(failed.localizedDescription)")
            }
    }
    
    /// Get Messages
    static func getMessages(for channel: ChannelItem, completion: @escaping([MessageItem]) -> Void) {
        FirebaseConstants.MessageChannelRef.child(channel.id)
            .observe(.value) { snapshot in
                guard let messagesDict = snapshot.value as? [String:Any] else { return }
                var messages: [MessageItem] = []
                messagesDict.forEach { key, value in
                    let messageDict = value as? [String:Any] ?? [:]
                    let message = MessageItem(id: key, dict: messageDict)
                    message.sender = channel.members.first(where: { $0.uid == message.ownerUid })
                    messages.append(message)
                    
                    if messages.count == snapshot.childrenCount {
                        messages.sort{ $0.timeStamp < $1.timeStamp }
                        completion(messages)
                    }
                }
            } withCancel: { failed in
                print("Failed to fetch all messages: \(failed.localizedDescription)")
            }
    }
    
    /// Send Text Message
    static func sendTextMessage(to channel: ChannelItem, from currentUser: UserItem, _ textMessage: String, _ uidReplyMessage: String?, _ messageReplyCurrnet: MessageItem? , onComplete: () -> Void) {
        
        let timestamp = Date().timeIntervalSince1970
        guard let messageId = FirebaseConstants.MessageChannelRef.childByAutoId().key else { return }
        
        let channelDict: [String:Any] = [
            .lastMessage: textMessage,
            .lastMessageTimestamp: timestamp,
            .lastMessageType: MessageType.text.title
        ]
        
        var messageDict: [String:Any] = [
            .id: messageId,
            .text: textMessage,
            .type: MessageType.text.title,
            .timeStamp: timestamp,
            .ownerUid: currentUser.uid
        ]
        
        if let uidReplyMessage {
            messageDict[.uidMessageReply] = uidReplyMessage
            switch messageReplyCurrnet?.type {
            case .text:
                messageDict[.replyType] = MessageReplyType.textReply.rawValue
            case .photo:
                messageDict[.replyType] = MessageReplyType.imageReply.rawValue
            case .video:
                messageDict[.replyType] = MessageReplyType.videoReply.rawValue
            case .audio:
                messageDict[.replyType] = MessageReplyType.audioReply.rawValue
            case .videoCall,.fileMedia,.location:
                messageDict[.replyType] = MessageReplyType.attachmentReply.rawValue
            case .sticker:
                messageDict[.replyType] = MessageReplyType.stickerReply.rawValue
            case .emoji:
                messageDict[.replyType] = MessageReplyType.likeReply.rawValue
            default:
                break
            }
        }
        
        FirebaseConstants.ChannelRef.child(channel.id).updateChildValues(channelDict)
        FirebaseConstants.MessageChannelRef.child(channel.id).child(messageId).setValue(messageDict)
        
        onComplete()
    }
    
    /// Send Emoji String Message
    static func sendEmojiStringMessage(to channel: ChannelItem, from currentUser: UserItem, _ emojiString: String, _ uidReplyMessage: String?, _ messageReplyCurrent: MessageItem? , onComplete: () -> Void) {
        let timestamp = Date().timeIntervalSince1970
        guard let messageId = FirebaseConstants.MessageChannelRef.childByAutoId().key else { return }
        
        let channeDict: [String:Any] = [
            .lastMessage: "",
            .lastMessageTimestamp: timestamp,
            .lastMessageType: MessageType.emoji.title
        ]
        
        var messageDict: [String:Any] = [
            .id: messageId,
            .text: "",
            .type: MessageType.emoji.title,
            .timeStamp: timestamp,
            .ownerUid: currentUser.uid,
            .emojiString: emojiString
        ]
        
        if let uidReplyMessage {
            messageDict[.uidMessageReply] = uidReplyMessage
            switch messageReplyCurrent?.type {
            case .text:
                messageDict[.replyType] = MessageReplyType.textReply.rawValue
            case .photo:
                messageDict[.replyType] = MessageReplyType.imageReply.rawValue
            case .video:
                messageDict[.replyType] = MessageReplyType.videoReply.rawValue
            case .audio:
                messageDict[.replyType] = MessageReplyType.audioReply.rawValue
            case .videoCall,.fileMedia,.location:
                messageDict[.replyType] = MessageReplyType.attachmentReply.rawValue
            case .sticker:
                messageDict[.replyType] = MessageReplyType.stickerReply.rawValue
            case .emoji:
                messageDict[.replyType] = MessageReplyType.likeReply.rawValue
            default:
                break
            }
        }
        
        FirebaseConstants.ChannelRef.child(channel.id).updateChildValues(channeDict)
        FirebaseConstants.MessageChannelRef.child(channel.id).child(messageId).setValue(messageDict)
        
        onComplete()
    }
    
    /// Send Sticker Message
    static func sendStickerMessage(to channel: ChannelItem, from currentUser: UserItem, _ stickerUrl: String, _ uidReplyMessage: String?, _ messageReplyCurrent: MessageItem? , onComplete: () -> Void) {
        
        let timestamp = Date().timeIntervalSince1970
        guard let messageId = FirebaseConstants.MessageChannelRef.childByAutoId().key else { return }
        
        let channelDict: [String:Any] = [
            .lastMessage: "",
            .lastMessageTimestamp: timestamp,
            .lastMessageType: MessageType.sticker.title
        ]
        
        var messageDict: [String:Any] = [
            .id: messageId,
            .text: "",
            .type: MessageType.sticker.title,
            .timeStamp: timestamp,
            .ownerUid: currentUser.uid,
            .urlSticker: stickerUrl
        ]
        
        if let uidReplyMessage {
            messageDict[.uidMessageReply] = uidReplyMessage
            switch messageReplyCurrent?.type {
            case .text:
                messageDict[.replyType] = MessageReplyType.textReply.rawValue
            case .photo:
                messageDict[.replyType] = MessageReplyType.imageReply.rawValue
            case .video:
                messageDict[.replyType] = MessageReplyType.videoReply.rawValue
            case .audio:
                messageDict[.replyType] = MessageReplyType.audioReply.rawValue
            case .videoCall,.fileMedia,.location:
                messageDict[.replyType] = MessageReplyType.attachmentReply.rawValue
            case .sticker:
                messageDict[.replyType] = MessageReplyType.stickerReply.rawValue
            case .emoji:
                messageDict[.replyType] = MessageReplyType.likeReply.rawValue
            default:
                break
            }
        }
        
        FirebaseConstants.ChannelRef.child(channel.id).updateChildValues(channelDict)
        FirebaseConstants.MessageChannelRef.child(channel.id).child(messageId).setValue(messageDict)
        
        onComplete()
    }
    
    /// Send Location Message
    static func sendLocationCurrentMessage(to channel: ChannelItem, from userCurrent: UserItem, _ location: LocationItem, _ uidReplyMessage: String?, _ messageReplyCurrent: MessageItem? , onComplete: () -> Void) {
        
        let timestamp = Date().timeIntervalSince1970
        guard let messageId = FirebaseConstants.MessageChannelRef.childByAutoId().key else { return }
        
        let channelDict: [String:Any] = [
            .lastMessage: "",
            .lastMessageTimestamp: timestamp,
            .lastMessageType: MessageType.location.title
        ]
        
        var messageDict: [String:Any] = [
            .id: messageId,
            .text: "",
            .type: MessageType.location.title,
            .timeStamp: timestamp,
            .ownerUid: userCurrent.uid,
            .location: [
                "latitude": Double(location.latitude),
                "longtitude": Double(location.longtitude),
                "nameAddress": location.nameAddress
            ]
        ]
        
        if let uidReplyMessage {
            messageDict[.uidMessageReply] = uidReplyMessage
            switch messageReplyCurrent?.type {
            case .text:
                messageDict[.replyType] = MessageReplyType.textReply.rawValue
            case .photo:
                messageDict[.replyType] = MessageReplyType.imageReply.rawValue
            case .video:
                messageDict[.replyType] = MessageReplyType.videoReply.rawValue
            case .audio:
                messageDict[.replyType] = MessageReplyType.audioReply.rawValue
            case .videoCall,.fileMedia,.location:
                messageDict[.replyType] = MessageReplyType.attachmentReply.rawValue
            case .sticker:
                messageDict[.replyType] = MessageReplyType.stickerReply.rawValue
            case .emoji:
                messageDict[.replyType] = MessageReplyType.likeReply.rawValue
            default:
                break
            }
        }
        
        FirebaseConstants.ChannelRef.child(channel.id).updateChildValues(channelDict)
        FirebaseConstants.MessageChannelRef.child(channel.id).child(messageId).setValue(messageDict)
        
        onComplete()
    }
    
    /// Send Video Call Message
    static func sendVideoCallMessage(to channel: ChannelItem, from currentUser: UserItem, _ timeVideoCall: TimeInterval, _ uidReplyMessage: String?, _ messageReplyCurrent: MessageItem? , onComplete: () -> Void) {
        
        let timestamp = Date().timeIntervalSince1970
        guard let messageId = FirebaseConstants.MessageChannelRef.childByAutoId().key else { return }
        
        let channelDict: [String:Any] = [
            .lastMessage: "",
            .lastMessageTimestamp: timestamp,
            .lastMessageType: MessageType.videoCall.title
        ]
        
        var messageDict: [String:Any] = [
            .id: messageId,
            .text: "",
            .type: MessageType.videoCall.title,
            .timeStamp: timestamp,
            .ownerUid: currentUser.uid,
            .videoCallDuration: timeVideoCall
        ]
        
        if let uidReplyMessage {
            messageDict[.uidMessageReply] = uidReplyMessage
            switch messageReplyCurrent?.type {
            case .text:
                messageDict[.replyType] = MessageReplyType.textReply.rawValue
            case .photo:
                messageDict[.replyType] = MessageReplyType.imageReply.rawValue
            case .video:
                messageDict[.replyType] = MessageReplyType.videoReply.rawValue
            case .audio:
                messageDict[.replyType] = MessageReplyType.audioReply.rawValue
            case .videoCall,.fileMedia,.location:
                messageDict[.replyType] = MessageReplyType.attachmentReply.rawValue
            case .sticker:
                messageDict[.replyType] = MessageReplyType.stickerReply.rawValue
            case .emoji:
                messageDict[.replyType] = MessageReplyType.likeReply.rawValue
            default:
                break
            }
        }
        
        FirebaseConstants.ChannelRef.child(channel.id).updateChildValues(channelDict)
        FirebaseConstants.MessageChannelRef.child(channel.id).child(messageId).setValue(messageDict)
        
        onComplete()
    }
    
    /// Send Media Message
    static func sendMediaMessage(to channel: ChannelItem, params: MessageMediaUploadParams, _ uidReplyMessage: String?, _ messageReplyCurrent: MessageItem? , completion: @escaping () -> Void) {
        guard let messageId = FirebaseConstants.MessageChannelRef.childByAutoId().key else { return }
        let timeStamp = Date().timeIntervalSince1970
        
        let channelDict: [String:Any] = [
            .lastMessage: params.text,
            .lastMessageTimestamp: timeStamp,
            .lastMessageType: params.type.title
        ]
        
        var messageDict: [String:Any] = [
            .id: messageId,
            .text: params.text,
            .type: params.type.title,
            .timeStamp: timeStamp,
            .ownerUid: params.ownerUid
        ]
        
        messageDict[.thumbnailUrl] = params.thumbnailUrl ?? nil
        messageDict[.thumbnailWidth] = params.thumbnailWidth ?? nil
        messageDict[.thumbnailHeight] = params.thumbnailHeight ?? nil
        messageDict[.videoURL] = params.videoURL ?? nil
        messageDict[.videoDuration] = params.videoDuration ?? nil
        messageDict[.audioURL] = params.audioURL ?? nil
        messageDict[.audioDuration] = params.audioDuration ?? nil
        messageDict[.fileMediaURL] = params.fileMediaURL ?? nil
        messageDict[.sizeOfFile] = params.sizeOfFile ?? nil
        messageDict[.nameOfFile] = params.nameOfFile ?? nil
        
        if let uidReplyMessage {
            messageDict[.uidMessageReply] = uidReplyMessage
            switch messageReplyCurrent?.type {
            case .text:
                messageDict[.replyType] = MessageReplyType.textReply.rawValue
            case .photo:
                messageDict[.replyType] = MessageReplyType.imageReply.rawValue
            case .video:
                messageDict[.replyType] = MessageReplyType.videoReply.rawValue
            case .audio:
                messageDict[.replyType] = MessageReplyType.audioReply.rawValue
            case .videoCall,.fileMedia,.location:
                messageDict[.replyType] = MessageReplyType.attachmentReply.rawValue
            case .sticker:
                messageDict[.replyType] = MessageReplyType.stickerReply.rawValue
            case .emoji:
                messageDict[.replyType] = MessageReplyType.likeReply.rawValue
            default:
                break
            }
        }
        
        /// Convert array levels audio
        if let audioLevels = params.audioLevels {
            messageDict[.audioLevels] = audioLevels.map({ Float($0) })
        }
        
        FirebaseConstants.ChannelRef.child(channel.id).updateChildValues(channelDict)
        FirebaseConstants.MessageChannelRef.child(channel.id).child(messageId).setValue(messageDict)
        
        completion()
    }
    
    /// Send reply story
    static func sendStoryReply(
        to channelUid: String,
        from currentUid: String,
        text: String,
        urlImageStory: String,
        completion: @escaping () -> Void
    ) {
        guard let messageId = FirebaseConstants.MessageChannelRef.childByAutoId().key else { return }
        let timeStamp = Date().timeIntervalSince1970
        
        let channelDict: [String:Any] = [
            .lastMessage: "",
            .lastMessageType: MessageType.replyStory.title,
            .lastMessageTimestamp: timeStamp
        ]
        
        let messageDict: [String:Any] = [
            .id: messageId,
            .text: text,
            .type: MessageType.replyStory.title,
            .timeStamp: timeStamp,
            .ownerUid: currentUid,
            .urlImageStory: urlImageStory
        ]
        
        FirebaseConstants.ChannelRef.child(channelUid).updateChildValues(channelDict)
        FirebaseConstants.MessageChannelRef.child(channelUid).child(messageId).setValue(messageDict)
        
        completion()
    }
    
    /// Send reply note
    static func sendNoteReply(
        to channelUid: String,
        from currentUid: String,
        text: String,
        textNote: String,
        completion: @escaping () -> Void
    ) {
        guard let messageId = FirebaseConstants.ChannelRef.childByAutoId().key else { return }
        let timeStamp = Date().timeIntervalSince1970
        
        let channelDict: [String:Any] = [
            .lastMessage: "",
            .lastMessageType: MessageType.replyNote.title,
            .lastMessageTimestamp: timeStamp
        ]
        
        let messageDict: [String:Any] = [
            .id: messageId,
            .text: text,
            .type: MessageType.replyNote.title,
            .timeStamp: timeStamp,
            .ownerUid: currentUid,
            .textNote: textNote
        ]
        
        FirebaseConstants.ChannelRef.child(channelUid).updateChildValues(channelDict)
        FirebaseConstants.MessageChannelRef.child(channelUid).child(messageId).setValue(messageDict)
        
        completion()
    }
    
    /// Fetch History Messages and Pagination
    static func getHistoryMessages(for channel: ChannelItem, lastCursor: String?, pageSize: UInt ,completion: @escaping(MessageNode) -> Void) {
        
        /// Setup Query
        let query: DatabaseQuery
        if lastCursor == nil {
            query = FirebaseConstants.MessageChannelRef.child(channel.id).queryLimited(toLast: pageSize)
        } else {
            query = FirebaseConstants.MessageChannelRef.child(channel.id)
                .queryOrderedByKey()
                .queryEnding(atValue: lastCursor)
                .queryLimited(toLast: pageSize)
        }
        
        /// Setup Listener
        query.observeSingleEvent(of: .value) { mainSnapshot in
            guard let first = mainSnapshot.children.allObjects.first as? DataSnapshot,
                  let allObjects = mainSnapshot.children.allObjects as? [DataSnapshot]
            else { return }
            
            var messages: [MessageItem] = allObjects.compactMap { messageSnapshot in
                let messageDict = messageSnapshot.value as? [String:Any] ?? [:]
                let message = MessageItem(id: messageDict[.id] as? String ?? "" ,dict: messageDict)
                
                if let messageReplyUid = message.uidMessageReply {
                    self.getMessage(channel.id, messageReplyUid) { messageItem in
                        if let messageItem {
                            message.messageReply = messageItem
                            message.messageReply?.sender = channel.members.first(where: { $0.uid == message.messageReply?.ownerUid })
                        }
                    }
                }
                
                /// Fetch Sender
                message.sender = channel.members.first(where: { $0.uid == message.ownerUid })
                
                return message
            }
            
            messages.sort { $0.timeStamp < $1.timeStamp }
            
            if messages.count == mainSnapshot.childrenCount {
                if lastCursor != nil {
                    messages.removeLast()
                }
                /// Filter the last message same with first message has been fetched
                let filterMessage = lastCursor == nil ? messages : messages.filter{ $0.id != lastCursor }

                let messageNode = MessageNode(messages: filterMessage, currentCursor: first.key)
                completion(messageNode)
            }
            
        } withCancel: { failed in
            print("Failed Get History Messages with error: \(failed.localizedDescription)")
            completion(.emptyNode)
        }
    }
    
    /// Listen new message when i've sent new message
    static func listenToMessage(
        _ channel: ChannelItem,
        onNewMessage: @escaping(MessageItem) -> Void,
        onUpdateMessages: @escaping(MessageItem) -> Void
    ) {
        let messageRef = FirebaseConstants.MessageChannelRef.child(channel.id)
        
        /// Listen new message
        messageRef
            .queryLimited(toLast: 1)
            .observe(.childAdded) { messageSnapshot in
                guard let messageDict = messageSnapshot.value as? [String:Any] else { return }
                let newMessage = MessageItem(id: messageSnapshot.key, dict: messageDict)
                if let messageReplyUid = newMessage.uidMessageReply {
                    self.getMessage(channel.id, messageReplyUid) { messageItem in
                        if let messageReplyUid = newMessage.uidMessageReply {
                            self.getMessage(channel.id, messageReplyUid) { messageItem in
                                if let messageItem {
                                    newMessage.messageReply = messageItem
                                    newMessage.messageReply?.sender = channel.members.first(where: { $0.uid == newMessage.messageReply?.ownerUid })
                                }
                            }
                        }
                    }
                }
                newMessage.sender = channel.members.first(where: { $0.uid == newMessage.ownerUid })
                onNewMessage(newMessage)
            }
        
        /// Listen for updated messages
        messageRef
            .observe(.childChanged) { messageSnapshot in
                guard let messageDict = messageSnapshot.value as? [String:Any] else { return }
                let updateMessage = MessageItem(id: messageSnapshot.key, dict: messageDict)
                if let messageReplyUid = updateMessage.uidMessageReply {
                    self.getMessage(channel.id, messageReplyUid) { messageItem in
                        if let messageItem {
                            updateMessage.messageReply = messageItem
                            updateMessage.messageReply?.sender = channel.members.first(where: { $0.uid == updateMessage.messageReply?.ownerUid })
                        }
                    }
                }
                updateMessage.sender = channel.members.first(where: { $0.uid == updateMessage.ownerUid })
                onUpdateMessages(updateMessage)
            }
    }
    
    /// Reaction message
    static func reactionMessage(
        _ channel: ChannelItem,
        message: MessageItem,
        emojis: [ReactionItem],
        completion: @escaping () -> Void
    ) {
        /// Convert to dict
        let emojisDict = emojis.compactMap{ $0.asDictionary }
        
        let messageDict: [String:Any] = [
            .emojis: emojisDict
        ]
                
        FirebaseConstants.MessageChannelRef.child(channel.id).child(message.id).updateChildValues(messageDict)
        
        completion()
    }
    
    /// Unsend message
    static func unSent(
        _ channel: ChannelItem,
        message: MessageItem,
        unsentMemberUids: [String],
        completion: @escaping () -> Void
    ) {
        let messageDict: [String:Any] = [
            .isUnsentUids: unsentMemberUids
        ]
        
        FirebaseConstants.MessageChannelRef.child(channel.id).child(message.id).updateChildValues(messageDict)
        
        completion()
    }
    
    
    /// Forward message to channel
    static func forwardMessageToChannel(
        _ channel: ChannelItem,
        messageForward: MessageItem,
        currentUser: UserItem,
        completion: @escaping (String) -> Void
    ) {
        guard let messageId = FirebaseConstants.ChannelRef.childByAutoId().key else { return }
        let timeStamp = Date().timeIntervalSince1970
        
        let channelDict: [String:Any] = [
            .lastMessage: "",
            .lastMessageType: messageForward.type.title,
            .lastMessageTimestamp: timeStamp
        ]
        
        var messageDict: [String:Any] = [
            .id: messageId,
            .text: messageForward.text,
            .type: messageForward.type.title,
            .timeStamp: timeStamp,
            .ownerUid: currentUser.uid
        ]
        
        messageDict[.thumbnailUrl] = messageForward.thumbnailUrl ?? nil
        messageDict[.thumbnailWidth] = messageForward.thumbnailWidth ?? nil
        messageDict[.thumbnailHeight] = messageForward.thumbnailHeight ?? nil
        messageDict[.videoURL] = messageForward.videoURL ?? nil
        messageDict[.videoDuration] = messageForward.videoDuration ?? nil
        messageDict[.audioURL] = messageForward.audioURL ?? nil
        messageDict[.audioDuration] = messageForward.audioDuration ?? nil
        messageDict[.fileMediaURL] = messageForward.fileMediaURL ?? nil
        messageDict[.sizeOfFile] = messageForward.sizeOfFile ?? nil
        messageDict[.nameOfFile] = messageForward.nameOfFile ?? nil
        messageDict[.emojiString] = messageForward.emojiString ?? nil
        messageDict[.urlSticker] = messageForward.urlSticker ?? nil
        
        if messageForward.type == .location, 
            let location = messageForward.location
        {
            messageDict[.location] = [
                "latitude": Double(location.latitude),
                "longtitude": Double(location.longtitude),
                "nameAddress": location.nameAddress
            ]
        }
        
        messageDict[.videoCallDuration] = messageForward.videoCallDuration ?? nil
        
        FirebaseConstants.ChannelRef.child(channel.id).updateChildValues(channelDict)
        FirebaseConstants.MessageChannelRef.child(channel.id).child(messageId).setValue(messageDict)
        
        completion(messageId)
    }
    
    
    /// Remove message from channel
    static func removeMessage(
        _ channel: ChannelItem,
        _ messageId: String,
        completion: @escaping () -> Void
    ) {
        FirebaseConstants.MessageChannelRef.child(channel.id).child(messageId)
            .removeValue { error, _ in
                if let error {
                    print("Failed to remove message: \(error.localizedDescription)")
                }
                
                completion()
            }
    }
}

struct MessageNode {
    var messages: [MessageItem]
    var currentCursor: String?
    static let emptyNode = MessageNode(messages: [], currentCursor: nil)
}

struct MessageMediaUploadParams {
    let channel: ChannelItem
    let text: String
    let type: MessageType
    let attachment: MediaAttachment
    var sender: UserItem
    var thumbnailUrl: String?
    var videoURL: String?
    var videoDuration: TimeInterval?
    var audioURL: String?
    var audioDuration: TimeInterval?
    var audioLevels: [Float]?
    var fileMediaURL: String?
    var sizeOfFile: Int64?
    var nameOfFile: String?
    
    var ownerUid: String {
        return sender.uid
    }
    
    var thumbnailWidth: CGFloat? {
        guard type == .photo else { return nil }
        return attachment.thumbnail.size.width
    }
    
    var thumbnailHeight: CGFloat? {
        guard type == .photo else { return nil }
        return attachment.thumbnail.size.height
    }
}
