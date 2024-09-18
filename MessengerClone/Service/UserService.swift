//
//  UserService.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 15/8/24.
//

import Foundation
import Firebase
import FirebaseDatabase

struct UserService {
    
    /// Pagination Users
    static func paginationUsers(lastCursor: String?, pageSize: UInt) async throws -> UserNode {
        let mainDataSnaphot: DataSnapshot
        
        if lastCursor == nil {
            mainDataSnaphot = try await FirebaseConstants.UserRef.queryLimited(toLast: pageSize).getData()
        } else {
            mainDataSnaphot = try await FirebaseConstants.UserRef
                .queryOrderedByKey()
                .queryEnding(atValue: lastCursor)
                .queryLimited(toLast: pageSize + 1)
                .getData()
        }
        
        guard let firstUser = mainDataSnaphot.children.allObjects.first as? DataSnapshot,
              let allUserObjects = mainDataSnaphot.children.allObjects as? [DataSnapshot]
        else {
            return UserNode.emptyNode
        }
        
        let users: [UserItem] = allUserObjects.compactMap { userSnapshot in
            let userDict = userSnapshot.value as? [String:Any] ?? [:]
            return UserItem(userDict)
        }
        
        /// If users has been converted has count(successfully convert) == mainDataSnapshot count before
        if users.count == mainDataSnaphot.childrenCount {
            /// Filter the duplicate first user current will be same will the last user in the before list
            let filteredDuplicateLastUser = lastCursor == nil
            ? users
            : users.filter{ $0.uid != lastCursor }
            
            let userNode = UserNode(users: filteredDuplicateLastUser, currentCursorUser: firstUser.key)
            
            return userNode
            
        } else {
            return .emptyNode
        }
    }
    
    /// Get users by userUids
    static func fetchUsersByUids(_ membersUids: [String], completion: @escaping (_ userNode: UserNode) -> Void){
        var users: [UserItem] = []
        for uid in membersUids {
            FirebaseConstants.UserRef.child(uid).observeSingleEvent(of: .value) { snapshot in
                guard let user = try? snapshot.data(as: UserItem.self) else { return }
                users.append(user)
                
                if users.count == membersUids.count {
                    completion(UserNode(users: users))
                }
            } withCancel: { failure in
                completion(.emptyNode)
            }
        }
    }
}

struct UserNode {
    var users: [UserItem]
    var currentCursorUser: String?
    static let emptyNode = UserNode(users: [], currentCursorUser: nil)
}
