//
//  ForwardSheetViewModel.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 21/10/24.
//

import Foundation
import FirebaseAuth

class ForwardSheetViewModel: ObservableObject {
    
    @Published var messageForward: MessageItem
    @Published var searchable: String = ""
    @Published var isSent: Bool = false
    @Published var currentUser: UserItem
    
    // MARK: Channel
    @Published var listChannel: [ChannelItem] = []
    // MARK: User
    @Published var listUser: [UserItem] = []
    private var lastCursor: String?
    var pagination: Bool {
        return !listUser.isEmpty
    }
    
    init(messageForward: MessageItem, _ userCurrent: UserItem) {
        self.messageForward = messageForward
        self.currentUser = userCurrent
//        Task {
//            try await fetchUsers()
//        }
    }
    
    /// FetchUsers
    func fetchUsers() async throws {
        do {
            let userNode = try await UserService.paginationUsers(lastCursor: self.lastCursor, pageSize: 10)
            self.listUser.append(contentsOf: userNode.users)
            self.lastCursor = userNode.currentCursorUser
            
            guard let currentUser = Auth.auth().currentUser?.uid else { return }
            self.listUser = self.listUser.filter{ $0.uid != currentUser }
        } catch {
            print("Failed fetch users from forward sheet: \(error.localizedDescription)")
        }
        
    }
    
    /// Fetch channels
    func fetchChannels() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        FirebaseConstants.UserChannelsRef.child(currentUid).observe(.value) { [weak self] snapshot in
            guard let dict = snapshot.value as? [String:Any] else { return }
            
            let group = DispatchGroup()
            
            dict.forEach { key, value in
                group.enter()
                let channelId = key
                self?.fetchChannelById(with: channelId) {
                    group.leave()
                }
            }
                        
            group.notify(queue: .main) {
                // This block will run once all channels have been fetched
                print("All channels have been fetched: \(self?.listChannel)")
            }
            
        } withCancel: { failure in
            print("Failed fetch channels by current Uid with error: \(failure.localizedDescription)")
        }
    }
    
    /// Fetch individual channel info
    func fetchChannelById(with uid: String, completion: @escaping () -> Void) {
        FirebaseConstants.ChannelRef.child(uid).observe(.value) { [weak self] snapshot in
            guard let self else {
                completion()
                return
            }
                        
            guard let dict = snapshot.value as? [String:Any] else { return }
            var channelItem = ChannelItem(dict)
            
            self.fetchUsersChannel(channelItem) { members in
                channelItem.members = members
                channelItem.members.append(self.currentUser)
                self.listChannel.append(channelItem)
                completion()
            }
            
        } withCancel: { failure in
            print("Failed fetch channel by uid with error: \(failure.localizedDescription)")
            completion()
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
}
