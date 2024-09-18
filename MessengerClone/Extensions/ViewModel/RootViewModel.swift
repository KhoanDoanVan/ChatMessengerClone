//
//  RootViewModel.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 13/8/24.
//
import Foundation
import Combine

class RootViewModel: ObservableObject {
    @Published private(set) var authState = AuthState.pending
    private var cancellables: AnyCancellable?
    
    init() {
        cancellables = AuthManager.shared.authState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] authState in
                self?.authState = authState
            }
                
//        AuthManager.testAccounts.forEach { email in
//            registerTestAccount(with: email)
//        }
    }
    
//    private func registerTestAccount(with email: String) {
//        Task {
//            let username = email.replacingOccurrences(of: "@test.com", with: "")
//            try? await AuthManager.shared.createAnAcounnt(for: username, with: email, and: "123456")
//        }
//    }
}
