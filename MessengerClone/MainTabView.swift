//
//  MainTabView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 24/7/24.
//

import SwiftUI

struct MainTabView: View {
    
    @State private var searchText = ""
    @State private var openCreateNewMessage = false
    @State private var tabViewOption: MainTabViewOption = .chat
    
    private var isSearchVisible: Bool {
        return tabViewOption == .chat
    }
    
    init() {
        makeTabBarOpaque()
    }
    
    var body: some View {
        VStack {
            TabView {
                ChatScreen()
                    .tabItem {
                        itemTab(.chat)
                    }
                    .onAppear {
                        tabViewOption = .chat
                    }
                
                Text("People")
                    .tabItem {
                        itemTab(.people)
                    }
                    .onAppear {
                        tabViewOption = .people
                    }
                
                StoryScreen()
                    .tabItem {
                        itemTab(.story)
                    }
                    .onAppear {
                        tabViewOption = .story
                    }
            }
            .tint(.messagesBlack)
        }
        .navigationTitle(tabViewOption.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            leadingButton()
            trailingButton(tabViewOption)
        }
        .sheet(isPresented: $openCreateNewMessage, content: {
            CreateChatView()
        })
        
        if isSearchVisible {
            Text("")
                .frame(height: 0)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        } else {
            Text("")
                .frame(height: 0)
        }
    }
    
    // Distransparent tab bar when over scroll
    private func makeTabBarOpaque() {
        
        /// Cancel Transparent bottom Tab bar
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        /// Cancel Transparent top Navigation bar
        let ap = UINavigationBarAppearance()
        ap.configureWithOpaqueBackground()
        UINavigationBar.appearance().standardAppearance = ap
        UINavigationBar.appearance().scrollEdgeAppearance = ap
    }

}

extension MainTabView {
    
    @ToolbarContentBuilder
    private func leadingButton() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                
            } label: {
                Image(systemName: "list.bullet")
                    .fontWeight(.bold)
            }
        }
    }
    
    @ToolbarContentBuilder
    private func trailingButton(_ tabItem: MainTabViewOption) -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                openCreateNewMessage.toggle()
            } label: {
                Image(systemName: tabItem.trailingIcon)
                    .fontWeight(.bold)
            }
        }
    }
    
    @ViewBuilder
    private func itemTab(_ itemTab: MainTabViewOption) -> some View {
        VStack {
            Image(systemName: itemTab.icon)
            Text(itemTab.title)
        }
    }
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
    NavigationStack {
        MainTabView()
    }
}
