//
//  NoteItem.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 8/10/24.
//

import Foundation

struct NoteItem {
    
    let id: String
    let text: String
    let timeStamp: Date
    let ownerUid: String
    let owner: UserItem?
    let songUrl: String?
    let songName: String?
    
}

