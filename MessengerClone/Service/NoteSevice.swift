//
//  NoteSevice.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 8/10/24.
//

import Foundation
import FirebaseAuth

struct NoteSevice {
    
    /// Upload a note
    static func uploadANote(_ text: String, completion: @escaping () -> Void) {
        
        guard let currentUid = Auth.auth().currentUser?.uid,
              let noteId = FirebaseConstants.UserNoteRef.childByAutoId().key
        else {
            completion()
            print("Invalid currentUid or noteId")
            return
        }
        
        let timestamp = Date().timeIntervalSince1970
        
        let dictNote: [String:Any] = [
            .id: noteId,
            .text: text,
            .timeStamp: timestamp,
            .ownerUid: currentUid
        ]
        
        FirebaseConstants.UserNoteRef.child(noteId).setValue(dictNote)
        
        completion()
    }
}
