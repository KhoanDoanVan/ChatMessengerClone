//
//  FirebaseConstants.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 13/8/24.
//

import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseDatabase

enum FirebaseConstants {
    static let StorageRef = Storage.storage().reference()
    static let FirestoreRef = Firestore.firestore()
    private static let DatabaseRef = Database.database().reference()
    static let UserRef = DatabaseRef.child("users")
    static let ChannelRef = DatabaseRef.child("channels")
    static let UserChannelsRef = DatabaseRef.child("user-channels")
    static let MessageChannelRef = DatabaseRef.child("messages-channel")
    static let UserDirectChannelsRef = DatabaseRef.child("user-direct-channels")
    static let UserStoryRef = DatabaseRef.child("user-stories")
    static let OnlineUserRef = DatabaseRef.child("user-online-state")
    static let UserNoteRef = DatabaseRef.child("user-note")
    static let MusicsRef = FirestoreRef.collection("musics")
}
