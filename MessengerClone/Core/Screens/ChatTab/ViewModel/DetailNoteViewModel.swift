//
//  DetailNoteViewModel.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 13/10/24.
//

import Foundation
import FirebaseAuth

class DetailNoteViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var note: NoteItem
    
    init(note: NoteItem) {
        self.note = note
    }
    
    /// Send Reply Note
    func sendReplyNote() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        getChannelFromCurrentAndOwnerStory(currentUid, note.ownerUid) { channelId in
            if let channelId {
                MessageService.sendNoteReply(to: channelId, from: currentUid, text: self.text, textNote: self.note.textNote) {
                    print("Successfully reply note to channelId: \(channelId)")
                    self.text = ""
                }
            }
        }
    }
}
