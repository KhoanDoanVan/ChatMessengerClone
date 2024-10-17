//
//  BubbleReplyMessageViewModel.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 17/10/24.
//

import Foundation

class BubbleReplyMessageViewModel: ObservableObject {
    @Published var channel: ChannelItem
    @Published var messageCurrent: MessageItem
    @Published var messageReply: MessageItem?
    
    init(_ message: MessageItem, _ channel: ChannelItem) {
        self.messageCurrent = message
        self.channel = channel
        
        guard let messageReplyId = messageCurrent.uidMessageReply else { return }
        
        MessageService.getMessage(channel.id, messageReplyId) { [weak self] messageReply in
            DispatchQueue.main.async {
                self?.messageReply = messageReply ?? MessageItem.stubMessageText
            }
        }
    }
    
    /// Fetch message reply
    //    private func fetchMessageReply() {
    //        guard let messageReplyId = messageCurrent.uidMessageReply else { return }
    //
    //        MessageService.getMessage(channel.id, messageReplyId) { [weak self] messageReply in
    //            DispatchQueue.main.async {
    //                self?.messageReply = messageReply ?? MessageItem.stubMessageText
    //            }
    //        }
    //    }
}
