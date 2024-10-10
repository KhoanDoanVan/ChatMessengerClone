//
//  NoteSevice.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 8/10/24.
//

import Foundation
import FirebaseAuth
import Firebase

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
    
    /// Remove  all note older 24 hours
    static func removeAllNotesOver24Hours(completion: @escaping () -> Void) {
        
        let twentyFourHoursAgo = Date().timeIntervalSince1970 * 1000 - (24 * 60 * 60 * 1000)
        
        FirebaseConstants.UserNoteRef
            .queryOrdered(byChild: "createAt")
            .queryEnding(atValue: twentyFourHoursAgo)
            .observeSingleEvent(of: .value) { snapshot in
                
                let dispatchGroup = DispatchGroup() // Dispatch group to manage async tasks
                
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    
                    if let noteData = snap.value as? [String:AnyObject],
                       let timeStamp = noteData["createAt"] as? Double,
                       timeStamp >= twentyFourHoursAgo
                    {
                        dispatchGroup.enter() // Start tracking the removal task
                        
                        snap.ref.removeValue { error, _ in
                            if let error {
                                print("Error to remove note: \(error.localizedDescription)")
                            } else {
                                print("Remove snap successfully.")
                            }
                            dispatchGroup.leave() // Mark the task as complete
                        }
                    }
                }
            
                // Once all remove tasks are complete, call the completion handler
               dispatchGroup.notify(queue: .main) {
                   completion()
               }
            }
    }
    
    /// Remove a note by Id
    static func removeANoteById(_ idNote: String, completion: @escaping (Error?) -> Void) {
        FirebaseConstants.UserNoteRef.child(idNote)
            .removeValue { error, _ in
                completion(error)
            }
    }
    
    /// Change a note
    static func changeANote(_ idNote: String, _ newText: String, completion: @escaping () -> Void) {
        
        let timeStamp = Date().timeIntervalSince1970
        
        let dict: [String:Any] = [
            .createAt: timeStamp,
            .textNote: newText
        ]
        
        FirebaseConstants.UserNoteRef.child(idNote).updateChildValues(dict)
        
        completion()
    }
}
