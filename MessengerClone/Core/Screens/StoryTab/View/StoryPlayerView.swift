//
//  StoryPlayerView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 2/10/24.
//

import SwiftUI
import Kingfisher

struct StoryPlayerView: View {
    
    @StateObject private var viewModel: StoryPlayerViewModel
    let handleAction: () -> Void
    
    init(storyGroup: GroupStoryItem, handleAction: @escaping () -> Void) {
        self.handleAction = handleAction
        self._viewModel = StateObject(wrappedValue: StoryPlayerViewModel(currentGroupStory: storyGroup))
    }
    
    var body: some View {
        ZStack {
            VStack {
                KFImage(URL(string: viewModel.storyCurrent.storyImageURL))
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 700)
                    .clipShape(
                        .rect(cornerRadius: 10)
                    )
                    .padding(.bottom, 50)
                Spacer()
            }
            topStory()
            bottomStory()
        }
    }
    
    /// Bottom Story
    private func bottomStory() -> some View {
        VStack {
            Spacer()
            if viewModel.isTyping || !viewModel.text.isEmpty {
                HStack(spacing: 10) {
                    TextField("", text: $viewModel.text, prompt: Text("Send message")
                        .bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray3))
                        .clipShape(Capsule())
                        .onTapGesture {
                            withAnimation {
                                viewModel.isTyping = true
                            }
                        }
                    
                    Button {
                        viewModel.sendStoryReply()
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.title2)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        TextField("", text: $viewModel.text, prompt: Text("Send message")
                            .bold())
                            .foregroundStyle(.white)
                            .frame(width: 220)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray3))
                            .clipShape(Capsule())
                            .padding(.leading, 10)
                            .onTapGesture {
                                withAnimation {
                                    viewModel.isTyping = true
                                }
                            }
                        
                        ForEach(Reaction.allCases, id: \.self) { reaction in
                            Button {
                                
                            } label: {
                                Text(reaction.emoji)
                                    .font(.system(size: 32))
                            }
                        }
                    }
                }
                .padding(.bottom, 10)
            }
        }
        .animation(.bouncy, value: viewModel.isTyping)
    }
    
    /// Top Story
    private func topStory() -> some View {
        VStack(spacing: 15) {
            topBarTimer()
            HStack {
                CircularProfileImage(viewModel.currentGroupStory.owner.profileImage, size: .xSmall)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(viewModel.currentGroupStory.owner.username)
                            .fontWeight(.bold)
                        Text(viewModel.currentGroupStory.stories[0].timeStamp.timeAgo())
                            .foregroundStyle(.gray)
                    }
                }
                Spacer()
                HStack(spacing: 20) {
                    Button {
                        
                    } label: {
                        Image(systemName: "ellipsis")
                            .bold()
                            .foregroundStyle(.white)
                            .font(.title)
                    }
                    Button {
                        handleAction()
                    } label: {
                        Image(systemName: "xmark")
                            .bold()
                            .foregroundStyle(.white)
                            .font(.title2)
                    }
                    .padding(.trailing, 5)
                }
            }
            Spacer()
        }
        .padding(.top)
        .padding(.horizontal, 10)
    }
    
    /// Top Timer
    private func topBarTimer() -> some View {
        HStack(spacing: 3) {
            ForEach(0..<viewModel.currentGroupStory.stories.count) { _ in
                Rectangle()
                    .frame(width: viewModel.widthOfTimeStory)
                    .frame(height: 2)
                    .foregroundStyle(.gray)
                    .clipShape(Capsule())
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .frame(width: viewModel.widthOfTimeStory, height: 2)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
            }
        }
        .padding(.horizontal, 5)
    }
}

#Preview {
    StoryPlayerView(storyGroup: .dummyGroupStory) {
        
    }
}
