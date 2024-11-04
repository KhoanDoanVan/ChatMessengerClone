//
//  SettingsView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 8/8/24.
//

import SwiftUI
import PhotosUI
import Toast

struct SettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SettingsViewModel
    
    let user: UserItem
    
    init(_ user: UserItem) {
        self.user = user
        _viewModel = StateObject(wrappedValue: SettingsViewModel(user))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                header()
                    .padding(.top)
                
                listAction()
                
                buttonSignOut()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                buttonLeading()
                buttonTrailing()
            }
        }
    }
    
    private func buttonSignOut() -> some View {
        Button {
            Task {
                try await AuthManager.shared.logOut()
                Toast.shared.present(title: "SignOut Successfully", symbol: "lock.shield")
            }
        } label: {
            Text("Sign Out")
                .foregroundStyle(Color(.systemRed))
        }
    }
    
    private func header() -> some View {
        VStack(spacing: 8) {
            if let profilePhoto = viewModel.profilePhoto {
                Image(uiImage: profilePhoto.thumbnail)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                CircularProfileImage(user.profileImage ,size: .custom(100))
            }
            Text(user.username)
                .font(.title2)
                .fontWeight(.bold)
            Button("Leave a note") {}
        }
    }
    
    private func listAction() -> some View {
        List {
            Section {
                ForEach(SettingsAction.settingTop.allCases) { action in
                    actionColumnTop(action)
                    .listRowBackground(Color(.systemGray5))
                }
            }
            
            Section {
                ForEach(SettingsAction.supervision.allCases) { action in
                    actionColumnSupervision(action)
                    .listRowBackground(Color(.systemGray5))
                }
            }
            
            Section {
                ForEach(SettingsAction.avatar.allCases) { action in
                    actionColumnAvatar(action)
                    .listRowBackground(Color(.systemGray5))
                }
            }
        }
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
    }
}

extension SettingsView {
    
    private func actionColumnTop(_ action: SettingsAction.settingTop) -> some View {
        Button {
            
        } label: {
            HStack {
                Image(systemName: action.icon)
                    .font(.callout)
                    .padding(8)
                    .background(action.colorBackground)
                    .clipShape(Circle())
                    .foregroundStyle(.white)
                Text(action.title)
                    .foregroundStyle(.messagesBlack)
            }
            .padding(.vertical, 2)
        }
    }
    
    private func actionColumnSupervision(_ action: SettingsAction.supervision) -> some View {
        Button {
            
        } label: {
            HStack {
                Image(systemName: action.icon)
                    .font(.callout)
                    .padding(8)
                    .background(action.colorBackground)
                    .clipShape(Circle())
                    .foregroundStyle(.white)
                Text(action.title)
                    .foregroundStyle(.messagesBlack)
            }
            .padding(.vertical, 2)
        }
    }
    
    private func actionColumnAvatar(_ action: SettingsAction.avatar) -> some View {
        
        PhotosPicker(selection: $viewModel.selectedPhotoItem) {
            HStack {
                Image(systemName: action.icon)
                    .font(.callout)
                    .padding(8)
                    .background(action.colorBackground)
                    .clipShape(Circle())
                    .foregroundStyle(.white)
                Text(action.title)
                    .foregroundStyle(.messagesBlack)
            }
            .padding(.vertical, 2)
        }
    }
    
    @ToolbarContentBuilder
    private func buttonLeading() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                
            } label: {
                Image(systemName: "qrcode.viewfinder")
                    .fontWeight(.bold)
            }
        }
    }
    
    @ToolbarContentBuilder
    private func buttonTrailing() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                if viewModel.profilePhoto != nil {
                    viewModel.uploadProfileImage()
                }
                dismiss()
            } label: {
                Text("Done")
                    .fontWeight(.bold)
            }
        }
    }
}

enum SettingsAction {
    enum settingTop: String, Identifiable, CaseIterable {
        case darkMode, activeStatus, accessibility, privacySafety
        
        var id: String {
            return rawValue
        }
        
        var title: String {
            switch self {
            case .darkMode:
                return "Dark Mode"
            case .activeStatus:
                return "Active status"
            case .accessibility:
                return "Accessibility"
            case .privacySafety:
                return "Privacy & safety"
            }
        }
        
        var icon: String {
            switch self {
            case .darkMode:
                return "moon.fill"
            case .activeStatus:
                return "message.badge.filled.fill"
            case .accessibility:
                return "accessibility.fill"
            case .privacySafety:
                return "lock.trianglebadge.exclamationmark.fill"
            }
        }
        
        var colorBackground: Color {
            switch self {
            case .darkMode:
                return Color(.systemGray3)
            case .activeStatus:
                return Color(.systemGreen)
            case .accessibility:
                return Color(.systemGray3)
            case .privacySafety:
                return Color(.systemBlue)
            }
        }
    }
    
    enum supervision: String, Identifiable, CaseIterable {
        case superVision
        
        var id: String {
            return rawValue
        }
        
        var title: String {
            switch self {
            case .superVision:
                return "Supervison"
            }
        }
        
        var icon: String {
            switch self {
            case .superVision:
                return "person.2.fill"
            }
        }
        
        var colorBackground: Color {
            switch self {
            case .superVision:
                return Color(.systemBlue)
            }
        }
    }
    
    enum avatar: String, Identifiable, CaseIterable {
        case avatar
        
        var id: String {
            return rawValue
        }
        
        var title: String {
            switch self {
            case .avatar:
                return "Avatar"
            }
        }
        
        var icon: String {
            switch self {
            case .avatar:
                return "person.crop.circle.fill"
            }
        }
        
        var colorBackground: Color {
            switch self {
            case .avatar:
                return Color(.systemPink)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(.placeholder)
    }
}
