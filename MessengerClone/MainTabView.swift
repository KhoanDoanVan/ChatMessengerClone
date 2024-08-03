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
                
                Text("Friends")
                    .tabItem {
                        itemTab(.people)
                    }
                
                Text("Locations")
                    .tabItem {
                        itemTab(.story)
                    }
            }
            .tint(.messagesBlack)
        }
        .navigationTitle("Chats")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            leadingButton()
            trailingButton()
        }
        .searchable(text: $searchText)
        .sheet(isPresented: $openCreateNewMessage, content: {
            CreateChatView()
        })
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
    private func trailingButton() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                openCreateNewMessage.toggle()
            } label: {
                Image(systemName: "square.and.pencil")
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
    case story = "Story"
    
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
}



#Preview {
    NavigationStack {
        MainTabView()
    }
}
