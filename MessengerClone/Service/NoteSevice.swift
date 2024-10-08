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
            .textNote: text,
            .createAt: timestamp,
            .ownerUid: currentUid
        ]
        
        FirebaseConstants.UserNoteRef.child(noteId).setValue(dictNote)
        
        completion()
    }
    
    /// Fetch all notes
    static func fetchAllNotes(completion: @escaping ([NoteItem]) -> Void) {
        
        FirebaseConstants.UserNoteRef
            .observe(.value) { snapshot  in
                guard let notesDict = snapshot.value as? [String:Any] else {
                    completion([])
                    return
                }
                
                var notes: [NoteItem] = []
                
                notesDict.forEach { key, value in
                    let noteDict = value as? [String:Any] ?? [:]
                    var note = NoteItem(noteDict)
                    
                    notes.append(note)
                }
                
                completion(notes)
                
            } withCancel: { error in
                print("Failed to fetch all notes: \(error.localizedDescription)")
            }
    }
}
