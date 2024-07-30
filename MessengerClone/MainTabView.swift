//
//  MainTabView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 24/7/24.
//

import SwiftUI

struct MainTabView: View {
    
    @State private var searchText = ""
    
    init() {
        makeTabBarOpaque()
    }
    
    var body: some View {
        VStack {
            TabView {
                ChatScreen()
                    .tabItem {
                        Image(systemName: "message")
                    }
                
                Text("Friends")
                    .tabItem {
                        Image(systemName: "person.2")
                    }
                
                Text("Locations")
                    .tabItem {
                        Image(systemName: "safari")
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
                
            } label: {
                Image(systemName: "square.and.pencil")
                    .fontWeight(.bold)
            }
        }
    }
}

#Preview {
    NavigationStack {
        MainTabView()
    }
}
