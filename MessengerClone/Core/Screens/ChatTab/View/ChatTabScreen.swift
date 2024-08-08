//
//  ChatScreen.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 24/7/24.
//

import SwiftUI

struct ChatTabScreen: View {
    
    @State private var searchText = ""
    @State private var openCreateNewMessage = false
    @Binding var showSidebarScreen: Bool
    
    init(showSidebarScreen: Binding<Bool>) {
        self._showSidebarScreen = showSidebarScreen
        self.makeTabBarOpaque()
    }
    
    var body: some View {
        
        NavigationStack {
            VStack(spacing: 0){
                List {
                    Section {
                        ListStoryView()
                            .listRowSeparator(.hidden)
                            .padding(.top)
                        ListChannelView()
                            .listRowSeparator(.hidden)
                    }
                    .listRowInsets(EdgeInsets())
                    .padding(.horizontal, 10)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Chats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                leadingButton()
                trailingButton()
            }
            .sheet(isPresented: $openCreateNewMessage, content: {
                CreateChatView()
            })
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
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

extension ChatTabScreen {
    @ToolbarContentBuilder
    private func leadingButton() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                showSidebarScreen.toggle()
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
}

#Preview {
    NavigationStack {
        ChatTabScreen(showSidebarScreen: .constant(false))
    }
}
