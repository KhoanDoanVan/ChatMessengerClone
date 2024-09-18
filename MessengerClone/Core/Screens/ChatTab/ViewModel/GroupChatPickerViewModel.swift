//
//  GroupChatPickerViewModel.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 10/8/24.
//

import FirebaseAuth
import Combine

enum ChannelCreateRoute {
    case groupChat
}

@MainActor
class GroupChatPickerViewModel: ObservableObject {
    @Published var navRoutes = [ChannelCreateRoute]()
    @Published var usersPicker: [UserItem] = []
    @Published var listUserSearch: [UserItem] = []
    @Published var search: String = ""
    @Published private(set) var users = [UserItem]()
    @Published var userCurrent: UserItem?
    @Published var subscription: AnyCancellable?
    
    // MARK: Create Channel Propertises
    var isDirectChannel: Bool {
        return usersPicker.count == 1
    }
    
    // MARK: Pagination User Propertises
    private var lastCursor: String?
    var isPagination: Bool {
        return !users.isEmpty
    }
    
    init() {
        listenForAuthState()
    }
    
    var showPickerList: Bool {
        return !usersPicker.isEmpty
    }
    
    var disableDone: Bool {
        return usersPicker.isEmpty
    }
    
    /// Fetch current User
    func listenForAuthState() {
        subscription = AuthManager.shared.authState
            .sink(receiveValue: { [weak self] state in
                switch state {
                case .loggedIn(let userCurrent):
                    self?.userCurrent = userCurrent
                    Task {
                        await self?.fetchUsers()
                    }
                default:
                    break
                }
            })
    }
    
    /// Action Picker User
    func handleActionPickerUser(_ user: UserItem) {
        if isPickerCheck(user) {
            removeUserPicker(user)
        } else {
            addUserPicker(user)
        }
    }
    
    /// Add the user
    func addUserPicker(_ user: UserItem) {
        usersPicker.append(user)
    }
    
    /// Remove the user outside the array
    func removeUserPicker(_ user: UserItem) {
        guard let index = usersPicker.firstIndex(where: { $0.uid == user.uid }) else { return }
        usersPicker.remove(at: index)
    }
    
    /// Check that user wheather inside the array picker or not
    func isPickerCheck(_ user: UserItem) -> Bool {
        return usersPicker.contains{ $0.uid == user.uid }
    }
    
    /// Searching function
    func searchUserPicker() {
        if search.isEmpty {
            self.listUserSearch = UserItem.placeholders
        } else {
            
            let listSearch = UserItem.placeholders.filter{ $0.username.lowercased().contains(search.lowercased())}
            DispatchQueue.main.async {
                self.listUserSearch = listSearch
            }
        }
    }
    
    // MARK: Create Direct Channel
    func createDirectChannel(_ userPartner: UserItem, completion: @escaping (_ newChannel: ChannelItem) -> Void) {
        
        if usersPicker.isEmpty {
            usersPicker.append(userPartner)
        }
        
        Task {
            
            /// If the partner created with user current and had the channel
            if let channelId = await verifyChannel(userPartner.uid) {
                
                let snapshot = try await FirebaseConstants.ChannelRef.child(channelId).getData()
                let channelDict = snapshot.value as! [String:Any]
                
                var directChannel = ChannelItem(channelDict)
                directChannel.members = usersPicker
                if let userCurrent {
                    directChannel.members.append(userCurrent)
                }
                
                completion(directChannel)
                
            /// If the channel hasn't been created with partner, let's create new channel
            } else {
                let channelCreation = createChannel(nil)
                switch channelCreation {
                case .success(let channel):
                    completion(channel)
                case .failure(let failure):
                    print(failure.localizedDescription)
                }
            }
        }
    }
    
    // MARK: Create Group Channel
    func createGroupChannel(_ groupName: String?, completion: @escaping (_ newChannel: ChannelItem) -> Void) {
        
        let result = createChannel(groupName)
        
        switch result {
        case .success(let newChannel):
            completion(newChannel)
        case .failure(let failure):
            print(failure.localizedDescription)
        }
    }
    
    // MARK: Create Channel
    func createChannel(_ channelName: String?) -> Result<ChannelItem, Error> {
        
        /// Check partner id has been inside the array picker yet
        guard !usersPicker.isEmpty else {
            return .failure(ChannelCreationError.noChatPartner)
        }
        
        /// Get id key and current user uid
        guard let channelId = FirebaseConstants.ChannelRef.childByAutoId().key,
              let currentUserId = Auth.auth().currentUser?.uid
        else {
            return .failure(ChannelCreationError.failedToCreateUniqueIds)
        }
        
        /// Create message Id
        guard let messageId = FirebaseConstants.MessageChannelRef.childByAutoId().key else {
            return .failure(ChannelCreationError.failedToCreateUniqueIds)
        }
        
        let timeStamp = Date().timeIntervalSince1970
        /// Get array uids members
        var memberUids = usersPicker.map { $0.uid }
        /// Append current uid
        memberUids.append(currentUserId)
        
        let newBroadcastAdmin = AdminMessageType.channelCreation.rawValue
        
        /// Channel dictionary
        var channelDict: [String: Any] = [
            .id: channelId,
            .lastMessageType: newBroadcastAdmin,
            .creationDate: timeStamp,
            .lastMessageTimestamp: timeStamp,
            .memberUids: memberUids,
            .adminUids: [currentUserId],
            .createdBy: currentUserId,
            .lastMessage: newBroadcastAdmin,
            .membersCount: memberUids.count
        ]
        
        /// Set channel name
        if let channelName = channelName,
           !channelName.isEmptyOrWhiteSpace {
            channelDict[.name] = channelName
        }
        
        /// Create first message admin
        let messageDict: [String:Any] = [
            .type: newBroadcastAdmin,
            .ownerUid: currentUserId,
            .timeStamp: timeStamp
        ]
        
        /// Set Value Channel Ref
        FirebaseConstants.ChannelRef.child(channelId).setValue(channelDict)
        
        /// Send Message to channel
        FirebaseConstants.MessageChannelRef.child(channelId).child(messageId).setValue(messageDict)
        
        /// Set Value for each user-channels
        memberUids.forEach { memberUid in
            FirebaseConstants.UserChannelsRef.child(memberUid).child(channelId).setValue(true)
        }
        
        /// Check create direct channel
        if isDirectChannel {
            let chatPartner = usersPicker[0]
            FirebaseConstants.UserDirectChannelsRef.child(currentUserId).child(chatPartner.uid).setValue([channelId: true])
            FirebaseConstants.UserDirectChannelsRef.child(chatPartner.uid).child(currentUserId).setValue([channelId: true])
        }
        
        /// New channel
        var newChannel = ChannelItem(channelDict)
        
        /// Set members userItem
        newChannel.members = usersPicker
        if let userCurrent {
            newChannel.members.append(userCurrent)
        }
        
        return .success(newChannel)
    }
    
    // MARK: Fetch Users By Pagination Users
    func fetchUsers() async {
        do {
            let userNode = try await UserService.paginationUsers(lastCursor: lastCursor, pageSize: 7)
            var fetchUsers = userNode.users
            
            /// Filter the current User
            guard let currentUser = Auth.auth().currentUser?.uid else { return }
            fetchUsers = fetchUsers.filter{ $0.uid != currentUser }
            
            /// Append users has been fetched to main users
            self.users.append(contentsOf: fetchUsers)
            self.lastCursor = userNode.currentCursorUser
        } catch {
            print("Failed to fetch users")
        }
    }
    
    // MARK: Verify Direct Channel Exists
    typealias ChannelId = String
    private func verifyChannel(_ chatPartnerId: String) async -> ChannelId? {
        guard let currentUid = Auth.auth().currentUser?.uid,
              let snapshot = try? await  FirebaseConstants.UserDirectChannelsRef.child(currentUid).child(chatPartnerId).getData(),
              snapshot.exists()
        else { return nil }
        
        let valueSnapshot = snapshot.value as! [String:Bool] // channelId: true
        let channelId = valueSnapshot.compactMap{ $0.key }.first
        
        return channelId
    }
}


enum ChannelCreationError: Error {
    case noChatPartner
    case failedToCreateUniqueIds
}
