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
    private var currentUser: UserItem
    @Published var channels = [ChannelItem]()
    
    // MARK: Avoid Duplication Channels When create new channel
    typealias ChannelId = String
    @Published var channelDictionary: [ChannelId: ChannelItem] = [:]
    
    init(_ currentUser: UserItem) {
        self.currentUser = currentUser
        fetchChannelsCurrent()
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
        
        UserService.fetchUsersByUids(membersUids) { userNode in
            completion(userNode.users)
        }
    }
    
    /// Reload Array Channels Realtime (avoid duplication after create new channel)
    func reloadChannelList() {
        self.channels = Array(channelDictionary.values)
    }
}
