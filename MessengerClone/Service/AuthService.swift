//
//  AuthService.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 13/8/24.
//

import Combine
import FirebaseAuth

// MARK: Protocal
protocol AuthService {
    static var shared: AuthService { get }
    
    /// It allows you to publish new values to its subscribers and also keeps track of the most recent value it published, which can be accessed directly.
    var authState: CurrentValueSubject<AuthState, Never> { get }
    
    func createAnAcounnt(for username: String, with email: String, and password: String) async throws
    func login(with email: String, and password: String) async throws
    func autoLogin() async
    func logOut() async throws
}

// MARK: Instance
final class AuthManager: AuthService {
    
    init() {
        Task {
            await self.autoLogin()
        }
    }
    
    static var shared: AuthService = AuthManager()
    
    /// State with Combine
    var authState = CurrentValueSubject<AuthState, Never>(.pending)
    
    /// Create an account
    func createAnAcounnt(for username: String, with email: String, and password: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let uuid = result.user.uid
            let newUserForRealtimeDB = UserItem(uid: uuid, username: username, email: email)
            try await saveUserInfoToRealtimeDB(user: newUserForRealtimeDB)
            self.authState.send(.loggedIn(newUserForRealtimeDB))
        } catch {
            print("Failed to create an account. Error: \(error.localizedDescription)")
            throw AuthError.signUpFailed(error.localizedDescription)
        }
    }
    
    /// Login
    func login(with email: String, and password: String) async throws {
        do {
            let _ = try await Auth.auth().signIn(withEmail: email, password: password)
            fetchCurrentInfo()
        } catch {
            print("Failed to login an account. Error: \(error.localizedDescription)")
            throw AuthError.signUpFailed(error.localizedDescription)
        }
    }
    
    /// Auto Login
    func autoLogin() async {
        if Auth.auth().currentUser == nil {
            authState.send(.loggedOut)
        } else {
            fetchCurrentInfo()
        }
    }
    
    /// Logout
    func logOut() async throws {
        do {
            try Auth.auth().signOut()
            authState.send(.loggedOut)
        } catch {
            print("Failed to Logout")
        }
    }
}

extension AuthManager {
    
    /// Save User Info to Realtime DB
    private func saveUserInfoToRealtimeDB(user: UserItem) async throws {
        do {
            let userDict: [String: Any] = [
                .uid: user.uid,
                .username: user.username,
                .email: user.email
            ]
            
            try await FirebaseConstants.UserRef.child(user.uid).setValue(userDict)
            
        } catch {
            throw AuthError.failedToSaveInfoUser(error.localizedDescription)
        }
    }
    
    /// Fetch User Current Info
    private func fetchCurrentInfo() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        FirebaseConstants.UserRef.child(currentUid).observeSingleEvent(of: .value) { snapshot in
            guard let userDict = snapshot.value as? [String: Any] else { return }
            let loggedUser = UserItem(userDict)
            self.authState.send(.loggedIn(loggedUser))
        } withCancel: { error in
            print(error.localizedDescription)
        }

    }
}

// MARK: Auth State
enum AuthState {
    case pending, loggedIn(UserItem), loggedOut
}

// MARK: Error Definition
enum AuthError: Error {
    case accountLoginFailed(_ description: String)
    case signUpFailed(_ description: String)
    case failedToSaveInfoUser(_ description: String)
}

extension AuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .accountLoginFailed(let description):
            return description
        case .signUpFailed(let description):
            return description
        case .failedToSaveInfoUser(let description):
            return description
        }
    }
}


extension AuthManager {
    static let testAccounts: [String] = [
        "QaUser1@test.com",
        "QaUser2@test.com",
        "QaUser3@test.com",
        "QaUser4@test.com",
        "QaUser5@test.com",
        "QaUser6@test.com",
        "QaUser7@test.com",
        "QaUser8@test.com",
        "QaUser9@test.com",
        "QaUser10@test.com",
        "QaUser11@test.com",
        "QaUser12@test.com",
        "QaUser13@test.com",
        "QaUser14@test.com",
        "QaUser15@test.com",
        "QaUser16@test.com",
        "QaUser17@test.com",
        "QaUser18@test.com",
        "QaUser19@test.com",
        "QaUser20@test.com",
        "QaUser21@test.com",
        "QaUser22@test.com",
        "QaUser23@test.com",
        "QaUser24@test.com",
        "QaUser25@test.com",
        "QaUser26@test.com",
        "QaUser27@test.com",
        "QaUser28@test.com",
        "QaUser29@test.com",
        "QaUser30@test.com",
        "QaUser31@test.com",
        "QaUser32@test.com",
        "QaUser33@test.com",
        "QaUser34@test.com",
        "QaUser35@test.com",
        "QaUser36@test.com",
        "QaUser37@test.com",
        "QaUser38@test.com",
        "QaUser39@test.com",
        "QaUser40@test.com",
        "QaUser41@test.com",
        "QaUser42@test.com",
        "QaUser43@test.com",
        "QaUser44@test.com",
        "QaUser45@test.com",
        "QaUser46@test.com",
        "QaUser47@test.com",
        "QaUser48@test.com",
        "QaUser49@test.com",
        "QaUser50@test.com",
    ]
}
