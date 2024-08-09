//
//  ConfigChatView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 9/8/24.
//

import SwiftUI

struct ConfigChatView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 30){
            header()
            headerAction()
            
            List {
                customizationSection()
                moreActionsSection()
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            buttonBack()
        }
    }
    
    private func headerAction() -> some View {
        HStack(spacing: 20) {
            ForEach(ActionConfigChat.HeaderActionConfig.allCases) { action in
                Button {
                    
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: action.icon)
                            .foregroundStyle(.messagesBlack)
                            .padding(5)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                        Text(action.title)
                            .font(.footnote)
                            .foregroundStyle(.messagesBlack)
                    }
                }
            }
        }
    }
    
    private func header() -> some View {
        VStack(spacing: 8) {
            Circle()
                .frame(width: 100, height: 100)
            Text("User name")
                .font(.title2)
                .fontWeight(.bold)
            Button {
                
            } label: {
                HStack(spacing: 0) {
                    Image(systemName: "lock.fill")
                    Text("End-to-end encrypted")
                }
                .font(.footnote)
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background(Color(.systemGray5))
                .cornerRadius(10)
            }
        }
    }
}

extension ConfigChatView {
    
    private func customizationSection() -> some View {
        Section {
            ForEach(ActionConfigChat.CustomizationConfig.allCases) { action in
                HStack {
                    Image(systemName: action.icon)
                        .bold()
                    Text(action.title)
                }
            }
        } header: {
            Text("Customization")
                .textCase(nil)
                .bold()
        }
    }
    
    private func moreActionsSection() -> some View {
        Section {
            ForEach(ActionConfigChat.MoreActionConfig.allCases) { action in
                HStack {
                    Image(systemName: action.icon)
                        .bold()
                    Text(action.title)
                }
            }
        } header: {
            Text("More actions")
                .textCase(nil)
                .bold()
        }
    }
    
    @ToolbarContentBuilder
    private func buttonBack() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
            }
        }
    }
}

enum ActionConfigChat {
    enum HeaderActionConfig: String, CaseIterable, Identifiable {
        case profile, mute
        
        var id: String {
            return rawValue
        }
        
        var title: String {
            switch self {
            case .profile:
                return "Profile"
            case .mute:
                return "Mute"
            }
        }
        
        var icon: String {
            switch self {
            case .profile:
                return "f.circle.fill"
            case .mute:
                return "bell.fill"
            }
        }
    }
    enum CustomizationConfig: String, CaseIterable, Identifiable {
        case theme, quickReaction, nicknames, wordEffects
        
        var id: String {
            return rawValue
        }
        
        var title: String {
            switch self {
            case .theme:
                return "Theme"
            case .quickReaction:
                return "Quick reaction"
            case .nicknames:
                return "Nicknames"
            case .wordEffects:
                return "Word effects"
            }
        }
        
        var icon: String {
            switch self {
            case .theme:
                return "circle.circle.fill"
            case .quickReaction:
                return "hand.thumbsup.fill"
            case .nicknames:
                return "textformat"
            case .wordEffects:
                return "lasso.badge.sparkles"
            }
        }
    }
    enum MoreActionConfig: String, CaseIterable, Identifiable {
        case viewMediaFilesLinks, searchInConversation, notificationAndSound, shareContact
        
        var id: String {
            return rawValue
        }
        
        var title: String {
            switch self {
            case .viewMediaFilesLinks:
                return "View media, files and links"
            case .searchInConversation:
                return "Search in conversation"
            case .notificationAndSound:
                return "Notifications & sounds"
            case .shareContact:
                return "Share contact"
            }
        }
        
        var icon: String {
            switch self {
            case .viewMediaFilesLinks:
                return "photo"
            case .searchInConversation:
                return "magnifyingglass"
            case .notificationAndSound:
                return "bell.fill"
            case .shareContact:
                return "square.and.arrow.up"
            }
        }
    }
}

#Preview {
    NavigationStack {
        ConfigChatView()
    }
}
