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
    
    @Published var listChannel: [ChannelItem] = []
    
    init(messageForward: MessageItem, _ userCurrent: UserItem) {
        self.messageForward = messageForward
        self.currentUser = userCurrent
        fetchChannels()
    }
    
    /// Fetch channels
    private func fetchChannels() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        FirebaseConstants.UserChannelsRef.child(currentUid).observeSingleEvent(of: .value) { [weak self] snapshot in
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
        FirebaseConstants.ChannelRef.child(uid).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self else { return }
            
            guard let dict = snapshot.value as? [String:Any] else { return }
            var channelItem = ChannelItem(dict)
            
            self.fetchUsersChannel(channelItem) { members in
                channelItem.members = members
                channelItem.members.append(self.currentUser)
                self.listChannel.append(channelItem)
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
}
