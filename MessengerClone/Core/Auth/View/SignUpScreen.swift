//
//  SignUpScreen.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 13/8/24.
//

import SwiftUI

struct SignUpScreen: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack {
            Image("messengerIcon")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .padding(.bottom, 50)
            Text("Registeration new account")
                .multilineTextAlignment(.center)
                .bold()
                .padding(.bottom, 20)
            
            VStack(spacing: 3) {
                fieldTextCustom(text: $viewModel.userName, placeholder: "Username")
                fieldTextCustom(text: $viewModel.emailOrPhone, placeholder: "Phone number or email")
                secureFieldTextCustom(text: $viewModel.password, placeholder: "Password")
            }
            .padding(.bottom)
            
            buttonAction(action: .register)
            buttonAction(action: .alreadyHaveAccount)
        }
        .navigationBarBackButtonHidden()
        .alert(isPresented: $viewModel.errorState.state) {
            Alert(
                title: Text(viewModel.errorState.messageError),
                dismissButton: .default(Text("OK 😭"))
            )
        }
    }
    
    private func handleActionSignUp(action: SignUpAction) {
        switch action {
        case .register:
            register()
        case .alreadyHaveAccount:
            alreadyHaveAccount()
        }
    }
    
    /// Registeration
    private func register() {
        Task {
            try await viewModel.register()
        }
    }
    
    /// Login
    private func alreadyHaveAccount() {
        dismiss()
    }
}

extension SignUpScreen {
    private func buttonAction(action: SignUpAction) -> some View {
        
        Button {
            handleActionSignUp(action: action)
        } label: {
            if action != .alreadyHaveAccount {
                Text(action.title)
                    .foregroundStyle(action == .register && viewModel.isSignUpValid ? .messagesBlack.opacity(0.3) : .messagesBlack)
                    .modifier(ButtonAuthModifier())
            } else {
                Text(action.title)
                    .font(.subheadline)
            }
        }
        .disabled(
            action == .register && viewModel.isSignUpValid
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

enum SignUpAction {
    case register, alreadyHaveAccount
    
    var title: String {
        switch self {
        case .register:
            return "Register"
        case .alreadyHaveAccount:
            return "Already have an account?"
        }
    }
}

#Preview {
    SignUpScreen(viewModel: AuthViewModel())
}
