//
//  ChatScreen.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 24/7/24.
//

import SwiftUI

struct ChatTabScreen: View {
    
    @State private var searchText = ""
    @StateObject private var viewModel: ChatTabScreenViewModel
    @Binding var showSidebarScreen: Bool
    
    init(
        showSidebarScreen: Binding<Bool>,
        userCurrent: UserItem
    ) {
        self._showSidebarScreen = showSidebarScreen
        self._viewModel = StateObject(wrappedValue: ChatTabScreenViewModel(userCurrent))
        self.makeTabBarOpaque()
    }
    
    var body: some View {
        
        NavigationStack(path: $viewModel.navRoutes) {
            VStack(spacing: 0){
                List {
                    ListNoteView(
                        listNotes: $viewModel.listNotes,
                        currentNote: $viewModel.currentNote
                    )
                    
                    ListChannelView(channels: viewModel.channels)
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Chats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                leadingButton()
                trailingButton()
            }
            .navigationDestination(isPresented: $viewModel.navigationToChatRoom, destination: {
                if let newChannel = viewModel.newChannel {
                    ChatRoomScreen(channel: newChannel)
                }
            })
            .navigationDestination(for: ChannelTabRoutes.self, destination: { route in
                destinationView(for: route)
            })
            .sheet(isPresented: $viewModel.openCreateNewMessage, content: {
                CreateChatView(onCreate: viewModel.createNewChat)
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
    
    @ViewBuilder
    private func destinationView(for route: ChannelTabRoutes) -> some View {
        switch route {
        case .chatRoom(let channel):
            ChatRoomScreen(channel: channel)
        }
    }
    
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
                viewModel.openCreateNewMessage.toggle()
            } label: {
                Image(systemName: "square.and.pencil")
                    .fontWeight(.bold)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatTabScreen(showSidebarScreen: .constant(false), userCurrent: .placeholder)
    }
}
