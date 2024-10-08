//
//  NoteItem.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 8/10/24.
//

import Foundation

struct NoteItem: Identifiable {
    
    let id: String
    let textNote: String
    let createAt: Date
    let ownerUid: String
    var owner: UserItem?
    var songUrl: String?
    var songName: String?
    
    static let stubNote: NoteItem = NoteItem(id: UUID().uuidString, textNote: "", createAt: Date(), ownerUid: "")
    
    static let stubNoteCurrent: NoteItem = NoteItem(id: "", textNote: "Post a note", createAt: Date(), ownerUid: "")
    
}
extension NoteItem {
    init(_ dict: [String:Any]) {
        self.id = dict[.id] as? String ?? ""
        self.textNote = dict[.textNote] as? String ?? ""
        let timeStamp = dict[.createAt] as? Double ?? 0
        self.createAt = Date(timeIntervalSince1970: timeStamp)
        self.ownerUid = dict[.ownerUid] as? String ?? ""
    }
}

extension String {
    static let textNote = "textNote"
    static let createAt = "createAt"
}
