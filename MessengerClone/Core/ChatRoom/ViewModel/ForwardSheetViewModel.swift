//
//  ForwardSheetViewModel.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 21/10/24.
//

import Foundation
import FirebaseAuth

enum UserState {
    case sending, sent, waiting
}

struct ForwardMessageAction: Hashable {
    let id: String = UUID().uuidString
    var channel: ChannelItem
    var state: UserState = .waiting
    var messageId: String?
}

class ForwardSheetViewModel: ObservableObject {
    
    @Published var messageForward: MessageItem
    @Published var searchable: String = ""
    @Published var isSent: Bool = false
    @Published var currentUser: UserItem
    @Published var currentChannel: ChannelItem
    
    // MARK: Channel
    @Published var listChannel: [ForwardMessageAction] = []
    // MARK: User
    @Published var listUser: [UserItem] = []
    private var lastCursor: String?
    var pagination: Bool {
        return !listUser.isEmpty
    }
    
    init(messageForward: MessageItem, _ userCurrent: UserItem, _ currentChannel: ChannelItem) {
        self.messageForward = messageForward
        self.currentUser = userCurrent
        self.currentChannel = currentChannel
        fetchChannels()
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
        FirebaseConstants.UserChannelsRef.child(currentUid).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let dict = snapshot.value as? [String:Any] else { return }
            
            let group = DispatchGroup()
            
            dict.forEach { key, value in
                group.enter()
                let channelId = key
                
                if channelId != self?.currentChannel.id {
                    self?.fetchChannelById(with: channelId) {
                        group.leave()
                    }
                } else {
                    group.leave()
                }
            }
            
        } withCancel: { failure in
            print("Failed fetch channels by current Uid with error: \(failure.localizedDescription)")
        }
    }
    
    /// Fetch individual channel info
    func fetchChannelById(with uid: String, completion: @escaping () -> Void) {
        FirebaseConstants.ChannelRef.child(uid).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self else {
                completion()
                return
            }
                        
            guard let dict = snapshot.value as? [String:Any] else { return }
            var channelItem = ChannelItem(dict)
            
            self.fetchUsersChannel(channelItem) { members in
                channelItem.members = members
                channelItem.members.append(self.currentUser)
                
                var forwardMessageAction = ForwardMessageAction(channel: channelItem)
                
                self.listChannel.append(forwardMessageAction)
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
    
    /// Action send message
    func actionSendMessage(_ channel: ForwardMessageAction) {
        
        guard let index = listChannel.firstIndex(where: { $0.id == channel.id }) else { return }
                
        if listChannel[index].state == .waiting {
            listChannel[index].state = .sending
            sendMessage(channel.channel) { [weak self] messageId in
                self?.listChannel[index].state = .sent
                self?.listChannel[index].messageId = messageId
            }
        } else {
            listChannel[index].state = .sending
            if let messageId = channel.messageId {
                removeMessage(channel.channel, messageId: messageId) { [weak self] in
                    self?.listChannel[index].state = .waiting
                    self?.listChannel[index].messageId = nil
                }
            }
        }
    }
    
    /// Send forward message
    private func sendMessage(_ channel: ChannelItem ,completion: @escaping (String) -> Void) {
        MessageService.forwardMessageToChannel(channel, messageForward: messageForward, currentUser: currentUser) { [weak self] messageId in
            completion(messageId)
        }
    }
    
    
    /// Remove forward message
    private func removeMessage(_ channel: ChannelItem, messageId: String, completion: @escaping () -> Void) {
        MessageService.removeMessage(channel, messageId) {
            completion()
        }
    }
}
