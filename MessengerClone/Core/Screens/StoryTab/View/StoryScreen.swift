//
//  StoryView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 4/8/24.
//

import SwiftUI

struct StoryScreen: View {
    @Binding var showSidebarScreen: Bool
    @StateObject private var viewModel = StoryViewModel()
    
    private var widthOfStory: CGFloat {
        return ((UIWindowScene.current?.screenWidth ?? 0) / 2) - 10
    }
    
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
                    if let groupCurrent = viewModel.groupStoryCurrent {
                        StoryCellView(groupStory: groupCurrent, isShowStory: false)
                            .onTapGesture {
                                viewModel.isOpenStoryPlayer.toggle()
                                viewModel.groupStoryTapGesture = groupCurrent
                            }
                    } else {
                        createStoryCell()
                            .onTapGesture {
                                viewModel.openCreateNewStory.toggle()
                            }
                    }
                    
                    if !viewModel.listGroupStory.isEmpty {
                        listCellStory()
                    } else {
                        ProgressView()
                    }
                }
            }
            .padding(.top)
            .navigationTitle("Chats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                leadingButton()
            }
            .sheet(isPresented: $viewModel.openCreateNewStory, content: {
                AddToStoryView() {
                    viewModel.openCreateNewStory.toggle()
                }
            })
            .fullScreenCover(isPresented: $viewModel.isOpenStoryPlayer) {
                if let groupStory = viewModel.groupStoryTapGesture {
                    StoryPlayerView(storyGroup: groupStory) {
                        viewModel.isOpenStoryPlayer.toggle()
                        viewModel.groupStoryTapGesture = nil
                    }
                }
            }
        }
    }
    
    /// List Cell Story
    private func listCellStory() -> some View {
        ForEach(viewModel.listGroupStory, id: \.self) { groupStory in
            StoryCellView(
                groupStory: groupStory,
                isShowStory: true
            )
            .onTapGesture {
                if viewModel.checkOwner(groupStory.id) {
                    viewModel.isOpenStoryPlayer.toggle()
                    viewModel.groupStoryTapGesture = groupStory
                } else {
                    viewModel.openCreateNewStory.toggle()
                }
            }
        }
    }
    
    /// Create Cell View
    private func createStoryCell() -> some View {
        Rectangle()
            .frame(width: widthOfStory, height: 250)
            .cornerRadius(20)
            .overlay(alignment: .topLeading) {
                Circle()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.white)
                    .padding([.top, .horizontal], 10)
                    .overlay {
                        Image(systemName: "plus")
                            .foregroundStyle(.black)
                            .padding(.top, 10)
                    }
            }
            .overlay(alignment: .bottomLeading) {
                Text("Add to story")
                    .foregroundStyle(.white)
                    .padding([.bottom, .horizontal], 10)
            }
            .foregroundStyle(.messagesWhite)
    }
    
    /// Distransparent tab bar when over scroll
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
