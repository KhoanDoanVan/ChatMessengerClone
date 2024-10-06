//
//  TrackingOnlineService.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 6/10/24.
//

import Foundation

class TrackingOnlineService {
    
    // Cteate Object State Online
    
    
    // MARK: - Observe: Fetch individual state online user
    static func observeStateOnlineUserByIds(_ uidUser: String, completion: @escaping (Bool, Date?) -> Void) {
        FirebaseConstants.OnlineUserRef.child(uidUser)
            .observe(.value) { dataSnapshot in
                guard let data = dataSnapshot.value as? [String:Any] else {
                    completion(false, nil)
                    print("Failed to convert State Online User dataSnapshot")
                    return
                }
                
                let stateOnline = data["isOnline"] as? Bool ?? false
                if let lastTimeStamp = data["lastActive"] as? Double {
                    let lastTime = Date(timeIntervalSince1970: lastTimeStamp / 1000) // Firebase stores in milliseconds, so divide by 1000
                    completion(stateOnline, lastTime)
                } else {
                    completion(stateOnline, nil) // Handle case where lastTime is not available
                }
            }
    }
    
    // MARK: - SingleObserve: Fetch individual state online user
    static func singleStateOnlineUserByIds(_ uidUser: String, completion: @escaping (Bool, Date?) -> Void) {
        FirebaseConstants.OnlineUserRef.child(uidUser)
            .observeSingleEvent(of: .value) { dataSnapshot in
                guard let data = dataSnapshot.value as? [String:Any] else {
                    completion(false, nil)
                    print("Failed to convert State Online User dataSnapshot")
                    return
                }
                
                let stateOnline = data["isOnline"] as? Bool ?? false
                if let lastTimeStamp = data["lastActive"] as? Double {
                    let lastTime = Date(timeIntervalSince1970: lastTimeStamp / 1000) // Firebase stores in milliseconds, so divide by 1000
                    completion(stateOnline, lastTime)
                } else {
                    completion(stateOnline, nil) // Handle case where lastTime is not available
                }
            }
    }
}
