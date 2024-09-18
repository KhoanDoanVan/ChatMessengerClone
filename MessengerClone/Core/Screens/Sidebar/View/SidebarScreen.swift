//
//  SidebarScreen.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 6/8/24.
//

import SwiftUI

struct SidebarScreen: View {
    
    @State private var actionSelected: SidebarAction = .chats
    
    let user: UserItem
    let actionHandle: (_ action: ActionOpenSheet) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            headerSidebar(user: user)
            actionList()
            moreActionList()
            listCommunities()
        }
        .frame(width: (UIWindowScene.current?.screenWidth ?? 0) - 50)
        .frame(maxHeight: .infinity)
        .background(.messagesGray)
        .padding(.top, -20)
    }
    
    private func actionList() -> some View {
        VStack(spacing: 3) {
            ForEach(SidebarAction.allCases) { action in
                buttonAction(action)
            }
        }
    }
    
    private func moreActionList() -> some View {
        List {
            Section {
                ForEach(MoreSidebarAction.allCases) { moreAction in
                    buttonMoreAction(moreAction)
                        .listRowInsets(EdgeInsets())
                        .background(.messagesGray)
                        .listRowSeparator(.hidden)
                }
            } header: {
                Text("More")
            }
        }
        .listStyle(.plain)
        .frame(height: 120)
        .scrollIndicators(.hidden)
    }
    
    private func listCommunities() -> some View {
        List {
            Section {
                ForEach(0..<12) { community in
                    buttonCommunity()
                        .listRowInsets(EdgeInsets())
                        .background(.messagesGray)
                        .listRowSeparator(.hidden)
                }
            } header: {
                HStack {
                    Text("Communities")
                    Spacer()
                    Button("Edit") {}.fontWeight(.bold)
                }
            }
        }
        .listStyle(.plain)
        .frame(maxWidth: .infinity)
        .scrollIndicators(.hidden)
    }
    
    // Header
    private func headerSidebar(user: UserItem) -> some View {
        HStack {
            HStack {
                CircularProfileImage(user.profileImage, size: .small)
                buttonSwitchAccount(user: user)
            }
            Spacer()
            buttonSettings()
        }
        .padding()
    }
    
    // Action
    private func buttonAction(_ action: SidebarAction) -> some View {
        Button {
            
        } label: {
            HStack {
                Image(systemName: action.icon)
                    .font(.title3)
                    .padding(10)
                    .background(Color(.systemGray2))
                    .cornerRadius(10)
                Text(action.title)
                    .fontWeight(.bold)
            }
            .foregroundStyle(.messagesBlack)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(actionSelected == action ? Color(.systemGray3) : Color(.messagesGray))
        .cornerRadius(15)
        .padding(.horizontal, 10)
    }
    
    // More action
    private func buttonMoreAction(_ action: MoreSidebarAction) -> some View {
        Button {
            
        } label: {
            HStack {
                Image(systemName: action.icon)
                    .font(.title3)
                    .padding(10)
                    .background(Color(.systemGray2))
                    .cornerRadius(10)
                Text(action.title)
                    .fontWeight(.bold)
            }
            .foregroundStyle(.messagesBlack)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .cornerRadius(15)
        .padding(.horizontal, 10)
    }
    
    // Communities
    private func buttonCommunity() -> some View {
        Button {
            
        } label: {
            HStack {
                Rectangle()
                    .frame(width: 50, height: 50)
                    .cornerRadius(10)
                Text("Community name")
                    .fontWeight(.bold)
            }
            .foregroundStyle(.messagesBlack)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .cornerRadius(15)
        .padding(.horizontal, 10)
    }
}

extension SidebarScreen {
    
    @ViewBuilder
    private func buttonSettings() -> some View {
        Button {
            actionHandle(.openSettings)
        } label: {
            Image(systemName: "gearshape.fill")
                .font(.title)
        }
    }
    
    @ViewBuilder
    private func buttonSwitchAccount(user: UserItem) -> some View {
        Button {
            actionHandle(.openSwitchAccount)
        } label: {
            HStack(spacing: 3) {
                Text(user.username)
                    .fontWeight(.bold)
                Image(systemName: "chevron.down")
            }
            .foregroundStyle(.messagesBlack)
        }
    }
}

enum MoreSidebarAction: String, Identifiable, CaseIterable {
    case friendRequests
    
    var id: String {
        return rawValue
    }
    
    var title: String {
        switch self {
        case .friendRequests:
            return "Friend requests"
        }
    }
    
    var icon: String {
        switch self {
        case .friendRequests:
            return "person.2.fill"
        }
    }
}

enum SidebarAction: String, Identifiable, CaseIterable {
    case chats, marketplace, messageRequests, archive
    
    var id: String {
        return rawValue
    }
    
    var title: String {
        switch self {
        case .chats:
            return "Chats"
        case .marketplace:
            return "Marketplace"
        case .messageRequests:
            return "Message Requests"
        case .archive:
            return "Archive"
        }
    }
    
    var icon: String {
        switch self {
        case .chats:
            return "message.fill"
        case .marketplace:
            return "house.fill"
        case .messageRequests:
            return "ellipsis.message.fill"
        case .archive:
            return "archivebox.fill"
        }
    }
}

#Preview {
    SidebarScreen(user: .placeholder) { action in
        
    }
}
