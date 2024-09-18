//
//  AuthViewModel.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 13/8/24.
//

import Foundation

@MainActor
class AuthViewModel: ObservableObject {
    @Published var emailOrPhone: String = ""
    @Published var password: String = ""
    @Published var userName: String = ""
    
    @Published var errorState: (messageError: String, state: Bool) = ("Error", false)
    
    var isLoginValid: Bool {
        return emailOrPhone.isEmpty || password.isEmpty
    }
    
    var isSignUpValid: Bool {
        return emailOrPhone.isEmpty || password.isEmpty || userName.isEmpty
    }
    
    /// Register
    func register() async throws {
        do {
            try await AuthManager.shared.createAnAcounnt(for: userName, with: emailOrPhone, and: password)
        } catch {
            errorState.messageError = "Failed to SignUp with error: \(error.localizedDescription)"
            errorState.state = true
        }
    }
    
    /// Login
    func login() async throws {
        do {
            try await AuthManager.shared.login(with: emailOrPhone, and: password)
        } catch {
            errorState.messageError = "Failed to Login with error: \(error.localizedDescription)"
            errorState.state = true
        }
    }
}
