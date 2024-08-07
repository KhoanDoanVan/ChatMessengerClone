//
//  StoryView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 4/8/24.
//

import SwiftUI

struct StoryScreen: View {
    
    @State private var openCreateNewStory = false
    @Binding var showSidebarScreen: Bool
    
    var items = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
    ]
    
    init(showSidebarScreen: Binding<Bool>) {
        self._showSidebarScreen = showSidebarScreen
        self.makeTabBarOpaque()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: items, spacing: 10) {
                    ForEach(0..<12) { _ in
                        StoryCellView() {
                            openCreateStory()
                        }
                    }
                }
            }
            .padding(.top)
            .navigationTitle("Chats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                leadingButton()
            }
            .sheet(isPresented: $openCreateNewStory, content: {
                AddToStoryView()
            })
        }
    }
    
    private func openCreateStory() {
        openCreateNewStory.toggle()
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

extension StoryScreen {
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
}

#Preview {
    NavigationStack {
        StoryScreen(showSidebarScreen: .constant(false))
    }
}
