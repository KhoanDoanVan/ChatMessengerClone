//
//  MessageService.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 18/8/24.
//

import Foundation
import Firebase

struct MessageService {
    
    /// Get only first an message
    static func getFirstMessage(_ channel: ChannelItem, completion: @escaping(MessageItem) -> Void) {
        FirebaseConstants.MessageChannelRef.child(channel.id)
            .queryLimited(toFirst: 1)
            .observeSingleEvent(of: .value) { snapshot in
                guard let messagesDict = snapshot.value as? [String:Any] else { return } // array dict
                
                messagesDict.forEach { key, value in
                    guard let messageDict = snapshot.value as? [String:Any] else { return }
                    var firstMessage = MessageItem(id: key, dict: messageDict)
                    firstMessage.sender = channel.members.first(where: { $0.uid == firstMessage.ownerUid })
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
                    var message = MessageItem(id: key, dict: messageDict)
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
    static func sendTextMessage(to channel: ChannelItem, from currentUser: UserItem, _ textMessage: String, onComplete: () -> Void) {
        
        let timestamp = Date().timeIntervalSince1970
        guard let messageId = FirebaseConstants.MessageChannelRef.childByAutoId().key else { return }
        
        let channelDict: [String:Any] = [
            .lastMessage: textMessage,
            .lastMessageTimestamp: timestamp,
            .lastMessageType: MessageType.text.title
        ]
        
        let messageDict: [String:Any] = [
            .id: messageId,
            .text: textMessage,
            .type: MessageType.text.title,
            .timeStamp: timestamp,
            .ownerUid: currentUser.uid
        ]
        
        FirebaseConstants.ChannelRef.child(channel.id).updateChildValues(channelDict)
        FirebaseConstants.MessageChannelRef.child(channel.id).child(messageId).setValue(messageDict)
        
        onComplete()
    }
    
    /// Send Sticker Message
    static func sendStickerMessage(to channel: ChannelItem, from currentUser: UserItem, _ stickerUrl: String, onComplete: () -> Void) {
        
        let timestamp = Date().timeIntervalSince1970
        guard let messageId = FirebaseConstants.MessageChannelRef.childByAutoId().key else { return }
        
        let channelDict: [String:Any] = [
            .lastMessage: "",
            .lastMessageTimestamp: timestamp,
            .lastMessageType: MessageType.sticker.title
        ]
        
        let messageDict: [String:Any] = [
            .id: messageId,
            .text: "",
            .type: MessageType.sticker.title,
            .timeStamp: timestamp,
            .ownerUid: currentUser.uid,
            .urlSticker: stickerUrl
        ]
        
        FirebaseConstants.ChannelRef.child(channel.id).updateChildValues(channelDict)
        FirebaseConstants.MessageChannelRef.child(channel.id).child(messageId).setValue(messageDict)
        
        onComplete()
    }
    
    /// Send Video Call Message
    static func sendVideoCallMessage(to channel: ChannelItem, from currentUser: UserItem, _ timeVideoCall: TimeInterval, onComplete: () -> Void) {
        
        let timestamp = Date().timeIntervalSince1970
        guard let messageId = FirebaseConstants.MessageChannelRef.childByAutoId().key else { return }
        
        let channelDict: [String:Any] = [
            .lastMessage: "",
            .lastMessageTimestamp: timestamp,
            .lastMessageType: MessageType.videoCall.title
        ]
        
        let messageDict: [String:Any] = [
            .id: messageId,
            .text: "",
            .type: MessageType.videoCall.title,
            .timeStamp: timestamp,
            .ownerUid: currentUser.uid,
            .videoCallDuration: timeVideoCall
        ]
        
        FirebaseConstants.ChannelRef.child(channel.id).updateChildValues(channelDict)
        FirebaseConstants.MessageChannelRef.child(channel.id).child(messageId).setValue(messageDict)
    }
    
    /// Send Media Message
    static func sendMediaMessage(to channel: ChannelItem, params: MessageMediaUploadParams, completion: @escaping () -> Void) {
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
        
        /// Convert array levels audio
        if let audioLevels = params.audioLevels {
            messageDict[.audioLevels] = audioLevels.map({ Float($0) })
        }
        
        FirebaseConstants.ChannelRef.child(channel.id).updateChildValues(channelDict)
        FirebaseConstants.MessageChannelRef.child(channel.id).child(messageId).setValue(messageDict)
        
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
                var message = MessageItem(id: messageDict[.id] as? String ?? "" ,dict: messageDict)
                
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
                var newMessage = MessageItem(id: messageSnapshot.key, dict: messageDict)
                newMessage.sender = channel.members.first(where: { $0.uid == newMessage.ownerUid })
                onNewMessage(newMessage)
            }
        
        /// Listen for updated messages
        messageRef
            .observe(.childChanged) { messageSnapshot in
                guard let messageDict = messageSnapshot.value as? [String:Any] else { return }
                var updateMessage = MessageItem(id: messageSnapshot.key, dict: messageDict)
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
