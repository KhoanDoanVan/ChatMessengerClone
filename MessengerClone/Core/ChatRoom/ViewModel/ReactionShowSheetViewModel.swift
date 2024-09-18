//
//  ReactionShowSheetViewModel.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 16/9/24.
//

import Foundation
import FirebaseAuth

class ReactionShowSheetViewModel: ObservableObject {
    
    @Published var message: MessageItem?
    @Published var channel: ChannelItem?
    @Published var listReactions = [ReactionItem]()
    @Published var currentUserUid: String?
    
    init(message: MessageItem? = nil, channel: ChannelItem) {
        self.message = message
        self.channel = channel
        if let message = message {
            self.listReactions = message.emojis ?? []
            addSenderToReactionItem()
        }
        self.currentUserUid = Auth.auth().currentUser?.uid ?? ""
    }
    
    /// Add sender into reaction item
    private func addSenderToReactionItem() {
        
        for i in 0..<self.listReactions.count {
            
            var reactionItem = listReactions[i]
            
            reactionItem.senderReaction = channel?.members.first(where: {
                $0.uid == reactionItem.ownerUid
            })
            reactionItem.id = UUID().uuidString
                        
            self.listReactions[i] = reactionItem
        }
    }
    
    /// Remove icon by message
    private func removeReaction(_ reactionItem: ReactionItem) -> [ReactionItem] {
        guard !listReactions.isEmpty else { return [] }
        
        if let index = listReactions.firstIndex(where: {
            $0.id == reactionItem.id
        }) {
            listReactions.remove(at: index)
        }
        
        return listReactions
    }
    
    /// Tap to remove
    func tapToRemoveReaction(_ reactionItem: ReactionItem) {
        let listReactions = removeReaction(reactionItem)
        
        guard let channel,
              let message
        else { return }
        
        MessageService.reactionMessage(channel, message: message, emojis: listReactions) {
            print("Success Remove Reaction")
        }
    }
}

