//
//  FirebaseConstants.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 13/8/24.
//

import Firebase
import FirebaseStorage

enum FirebaseConstants {
    static let StorageRef = Storage.storage().reference()
    private static let DatabaseRef = Database.database().reference()
    static let UserRef = DatabaseRef.child("users")
    static let ChannelRef = DatabaseRef.child("channels")
    static let UserChannelsRef = DatabaseRef.child("user-channels")
    static let MessageChannelRef = DatabaseRef.child("messages-channel")
    static let UserDirectChannelsRef = DatabaseRef.child("user-direct-channels")
    static let UserStoryRef = DatabaseRef.child("user-stories")
}
