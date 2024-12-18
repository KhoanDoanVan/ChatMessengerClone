//
//  ChatTabScreenViewModel.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 9/8/24.
//

import Foundation
import FirebaseAuth

enum ChannelTabRoutes: Hashable {
    case chatRoom(_ newChannel: ChannelItem)
}

class ChatTabScreenViewModel: ObservableObject {
    
    // MARK: Navigation Create Channel Propertises
    @Published var navRoutes = [ChannelTabRoutes]()
    @Published var openCreateNewMessage = false
    @Published var navigationToChatRoom = false
    @Published var newChannel: ChannelItem?
    
    // MARK: Fetch Channels Propertises
    var currentUser: UserItem
    @Published var channels = [ChannelItem]()
    
    // MARK: Avoid Duplication Channels When create new channel
    typealias ChannelId = String
    @Published var channelDictionary: [ChannelId: ChannelItem] = [:]
    
    // MARK: Note
    @Published var listNotes = [NoteItem]()
    @Published var currentNote: NoteItem?
    
    init(_ currentUser: UserItem) {
        self.currentUser = currentUser
        fetchChannelsCurrent()
        fetchAllNotes()
    }
    
    /// Create new chat
    func createNewChat(_ channel: ChannelItem) {
        openCreateNewMessage = false
        navigationToChatRoom = true
        newChannel = channel
    }
    
    /// Fetch channels by Current User
    func fetchChannelsCurrent() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        FirebaseConstants.UserChannelsRef.child(currentUid).observe(.value) { [weak self] snapshot in
            guard let dict = snapshot.value as? [String:Any] else { return }
            dict.forEach { key, value in
                let channelId = key
                self?.fetchChannelById(with: channelId)
            }
        } withCancel: { failure in
            print("Failed fetch channels by current Uid with error: \(failure.localizedDescription)")
        }
    }
    
    /// Fetch individual channel info
    func fetchChannelById(with uid: String) {
        FirebaseConstants.ChannelRef.child(uid).observe(.value) { [weak self] snapshot in
            guard let self else { return }
            
            guard let dict = snapshot.value as? [String:Any] else { return }
            var channelItem = ChannelItem(dict)
            /// Get users of channel
            self.fetchUsersChannel(channelItem) { members in
                channelItem.members = members
                channelItem.members.append(self.currentUser)
                self.channelDictionary[uid] = channelItem
                self.reloadChannelList()
            }
            
        } withCancel: { failure in
            print("Failed fetch channel by uid with error: \(failure.localizedDescription)")
        }
    }
    
    /// Fetch members(UserItem) of channel
    func fetchUsersChannel(_ channel: ChannelItem, completion: @escaping (_ members: [UserItem]) -> Void) {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        let membersUids = Array(channel.memberUids.filter{ $0 != currentUserUid })
        
        UserService.fetchUsersByUids(membersUids) { users in
            completion(users)
        }
    }
    
    /// Reload Array Channels Realtime (avoid duplication after create new channel)
    func reloadChannelList() {
        self.channels = Array(channelDictionary.values)
    }
    
    /// Fetch All Notes
    func fetchAllNotes() {
        
        NoteSevice.removeAllNotesOver24Hours {
            NoteSevice.fetchAllNotes { notes in
                self.listNotes = notes
                self.attachOwnerNote {
                    self.filterCurrentNote() {
                        self.attachOwnerOnline()
                    }
                }
            }
        }
    }
    
    
    /// Attach owner into note
    private func attachOwnerNote(completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup() // Use a dispatch group to manage asynchronous tasks
        
        for index in 0..<listNotes.count {
            let ownerUid = listNotes[index].ownerUid
            dispatchGroup.enter() // Start tracking the async task
            
            UserService.fetchUserByUid(ownerUid) { [weak self] userItem in
                defer { dispatchGroup.leave() } // Mark the async task as finished
                
                guard let self = self else { return }
                if index < self.listNotes.count {
                    self.listNotes[index].owner = userItem
                }
            }
        }
        
        // Notify when all async tasks have finished
        dispatchGroup.notify(queue: .main) {
            completion() // Completion handler to notify when owners have been attached
        }
    }
    
    /// Filter current note
    private func filterCurrentNote(completion: @escaping () -> Void) {
        if listNotes.contains(where: { $0.ownerUid == currentUser.uid }) {
            self.currentNote = listNotes.first(where: { $0.ownerUid == currentUser.uid })
            self.listNotes = listNotes.filter{ $0.ownerUid != currentUser.uid }
            print("ListNoteAfterFilter: \(listNotes)")
            completion()
        }
    }
    
    /// Remove a note by id
    func removeANote(_ idNote: String) {
        NoteSevice.removeANoteById(idNote) {[weak self] error in
            if let error {
                print("Error Remove a note: \(error)")
            } else {
                self?.currentNote = nil
                print("Delete note successfully")
            }
        }
    }
    
    /// Attach Owner Online to note
    private func attachOwnerOnline() {
        for index in 0..<listNotes.count {
            let ownerUid = listNotes[index].ownerUid
            TrackingOnlineService.singleStateOnlineUserByIds(ownerUid) { state, date in
                if let date {
                    self.listNotes[index].isOwnerOnline = (state, date)
                }
            }
        }
    }
}
