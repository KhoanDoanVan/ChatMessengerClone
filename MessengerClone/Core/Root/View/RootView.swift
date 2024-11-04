//
//  RootView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 13/8/24.
//

import SwiftUI
import Toast

struct RootView: View {
    @StateObject private var viewModel = RootViewModel()
    
    var body: some View {
        RootViewWithToast {
            Group {
                switch viewModel.authState {
                case .pending:
                    ProgressView()
                        .controlSize(.large)
                case .loggedIn(let user):
                    MainTabView(user)
                case .loggedOut:
                    LoginScreen()
                }
            }
        }
    }
}

#Preview {
    RootView()
}
