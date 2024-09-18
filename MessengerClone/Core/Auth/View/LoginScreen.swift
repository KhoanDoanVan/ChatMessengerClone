//
//  LoginScreen.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 13/8/24.
//

import SwiftUI

struct LoginScreen: View {
    
    @StateObject var viewModel = AuthViewModel()
    @State private var isDestination: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Image("messengerIcon")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .padding(.bottom, 50)
                Text("Log in with your phone number or Facebook account")
                    .multilineTextAlignment(.center)
                    .bold()
                    .padding(.bottom, 20)
                
                VStack(spacing: 3) {
                    fieldTextCustom(text: $viewModel.emailOrPhone, placeholder: "Phone number or email")
                    secureFieldTextCustom(text: $viewModel.password, placeholder: "Password")
                }
                .padding(.bottom)
                
                buttonAction(action: .login)
                buttonAction(action: .createNewAccount)
                buttonAction(action: .forgotPassword)
            }
            .navigationDestination(isPresented: $isDestination) {
                SignUpScreen(viewModel: viewModel)
            }
            .alert(isPresented: $viewModel.errorState.state) {
                Alert(
                    title: Text(viewModel.errorState.messageError),
                    dismissButton: .default(Text("OK 😭"))
                )
            }
        }
    }
    
    private func handleActionLogin(action: LoginScreenAction) {
        switch action {
        case .login:
            login()
        case .createNewAccount:
            register()
        case .forgotPassword:
            forgotPassword()
        }
    }
    
    /// Login
    private func login() {
        Task {
            try await viewModel.login()
        }
    }
    
    /// Register
    private func register() {
        isDestination.toggle()
    }
    
    /// Forgot password
    private func forgotPassword() {
        
    }
}

extension LoginScreen {
    private func buttonAction(action: LoginScreenAction) -> some View {
        
        Button {
            handleActionLogin(action: action)
        } label: {
            if action != .forgotPassword {
                Text(action.title)
                    .foregroundStyle(action == .login && viewModel.isLoginValid ? .messagesBlack.opacity(0.3) : .messagesBlack)
                    .modifier(ButtonAuthModifier())
            } else {
                Text(action.title)
                    .font(.subheadline)
            }
        }
        .disabled(
            action == .login && viewModel.isLoginValid
        )
        .padding(.top, 10)
    }
    
    private func fieldTextCustom(text: Binding<String>, placeholder: String) -> some View {
        TextField(
            "",
            text: text,
            prompt: Text("\(placeholder)")
        )
        .modifier(TextFieldAuthModifier())
    }
    
    private func secureFieldTextCustom(text: Binding<String>, placeholder: String) -> some View {
        SecureField(
            "",
            text: text,
            prompt: Text("\(placeholder)")
        )
        .modifier(TextFieldAuthModifier())
    }
}

enum LoginScreenAction {
    case login, createNewAccount, forgotPassword
    
    var title: String {
        switch self {
        case .login:
            return "Log in"
        case .createNewAccount:
            return "Create new account"
        case .forgotPassword:
            return "Forgot Password?"
        }
    }
}

#Preview {
    LoginScreen()
}
