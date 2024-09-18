//
//  MainTabView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 24/7/24.
//

import SwiftUI

struct MainTabView: View {
    
    @State private var offset: CGFloat = 0
    @State private var lastStoredOffset: CGFloat = 0
    @State private var showSidebarScreen: Bool = false
    @State private var openSettings: Bool = false
    @State private var openSwitchAccount: Bool = false
    
    private var userCurrent: UserItem

    init(_ currentUser: UserItem) {
        self.userCurrent = currentUser
    }
    
    var body: some View {
        
        let sideBarWidth = (UIWindowScene.current?.screenWidth ?? 0) - 50
        
        HStack(spacing: 0) {
            SidebarScreen(user: userCurrent) { action in
                handleAction(action)
            }
            
            TabView {
                ChatTabScreen(
                    showSidebarScreen: $showSidebarScreen,
                    userCurrent: userCurrent
                )
                    .tabItem {
                        itemTab(.chat)
                    }
                
                PeopleScreen(showSidebarScreen: $showSidebarScreen)
                    .tabItem {
                        itemTab(.people)
                    }
                
                StoryScreen(showSidebarScreen: $showSidebarScreen)
                    .tabItem {
                        itemTab(.story)
                    }
            }
            .frame(width: UIWindowScene.current?.screenWidth ?? 0)
            .overlay (
                Rectangle()
                    .fill(
                        Color.primary
                            .opacity(Double(offset / sideBarWidth / 10))
                    )
                    .ignoresSafeArea(.container, edges: .vertical)
                    .onTapGesture {
                        withAnimation {
                            showSidebarScreen.toggle()
                        }
                    }
            )
        }
        .frame(width: (UIWindowScene.current?.screenWidth ?? 0) + sideBarWidth)
        .offset(x : -sideBarWidth / 2)
        .offset(x : offset)
        .animation(.easeIn, value: offset == 0)
        .onChange(of: showSidebarScreen) {
            if showSidebarScreen && offset == 0 {
                offset = sideBarWidth
                lastStoredOffset = offset
            }
            
            if !showSidebarScreen && offset == sideBarWidth {
                offset = 0
                lastStoredOffset = 0
            }
        }
        .sheet(isPresented: $openSettings, content: {
            SettingsView(userCurrent)
        })
        .sheet(isPresented: $openSwitchAccount, content: {
            SwitchAccountView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.blue.opacity(0.2))
                .presentationDetents([.large, .height(500)])
        })
    }
    
    private func handleAction(_ actionSheet: ActionOpenSheet) {
        switch actionSheet {
        case .openSettings:
            openSettingsSheet()
        case .openSwitchAccount:
            openSwitchAccountSheet()
        }
    }
    
    private func openSettingsSheet() {
        openSettings.toggle()
    }
    
    private func openSwitchAccountSheet() {
        openSwitchAccount.toggle()
    }
}

extension MainTabView {
    
    @ViewBuilder
    private func itemTab(_ itemTab: MainTabViewOption) -> some View {
        VStack {
            Image(systemName: itemTab.icon)
            Text(itemTab.title)
        }
    }
}

enum ActionOpenSheet {
    case openSettings, openSwitchAccount
}

enum MainTabViewOption: String {
    case chat = "Chat"
    case people = "People"
    case story = "Stories"
    
    var icon: String {
        switch self {
        case .chat:
            return "message"
        case .people:
            return "person.2"
        case .story:
            return "safari"
        }
    }
    
    var title: String {
        return rawValue
    }
    
    var trailingIcon: String {
        switch self {
        case .chat:
            return "square.and.pencil"
        case .people:
            return "person.crop.rectangle.stack"
        default:
            return ""
        }
    }
}



#Preview {
    MainTabView(.placeholder)
}
