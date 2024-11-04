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
    
    @State private var overlayWindow: UIWindow?
    
    var body: some View {
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
        .onAppear {
            setUpToastGroupView()
        }
    }
    
    /// Set Up Toast Group View
    private func setUpToastGroupView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           overlayWindow == nil
        {
            let window = PassThroughWindow(windowScene: windowScene)
            window.backgroundColor = .clear
            
            /// View Controller
            let rootController = UIHostingController(rootView: ToastGroup())
            rootController.view.frame = windowScene.keyWindow?.frame ?? .zero
            rootController.view.backgroundColor = .clear
            
            window.rootViewController = rootController
            window.isHidden = false
            window.isUserInteractionEnabled = false
            window.tag = 1000
            
            overlayWindow = window
        }
    }
}

//#Preview {
//    RootView()
//}
