//
//  ReactionPickerMenuViewModel.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 13/9/24.
//

import Foundation
import FirebaseAuth

struct EmojiReaction {
    let reaction: Reaction
    var isAnimating: Bool = false
    var opacity: CGFloat = 1
}

class ReactionPickerMenuViewModel: ObservableObject {
    
    // MARK: Emoji
    @Published var emojis: [EmojiReaction] = [
        EmojiReaction(reaction: .like), EmojiReaction(reaction: .heart), EmojiReaction(reaction: .laugh), EmojiReaction(reaction: .shocked), EmojiReaction(reaction: .sad), EmojiReaction(reaction: .pray)
    ]
    
    // MARK: Properties
    @Published var message: MessageItem?
    @Published var channel: ChannelItem?
    
    // MARK: Init
    init(message: MessageItem, channel: ChannelItem) {
        self.message = message
        self.channel = channel
    }
    
    /// Reaction message
    func reactionMessage(_ emoji: String) {
        guard let userCurrent = Auth.auth().currentUser?.uid
        else { return }
        
        /// Reaction Item
        let reactionItem = ReactionItem(ownerUid: userCurrent, reaction: emoji)
        
        /// Append emoji
        guard let arrayEmojis = appendEmoji(reactionItem),
              let channel,
              let message
        else { return }
        
        
        /// Send Reaction
        MessageService.reactionMessage(channel, message: message, emojis: arrayEmojis) {
            self.message = nil
            self.channel = nil
        }
    }
    
    /// Append
    private func appendEmoji(_ emoji: ReactionItem) -> [ReactionItem]? {
        var reactionArray: [ReactionItem]?
        
        if message?.emojis == nil {
            reactionArray = []
            reactionArray?.append(emoji)
        } else {
            reactionArray = message?.emojis
            reactionArray?.append(emoji)
        }
        
        return reactionArray
    }
}
