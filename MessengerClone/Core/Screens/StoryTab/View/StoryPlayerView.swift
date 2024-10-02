//
//  StoryPlayerView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 2/10/24.
//

import SwiftUI

struct StoryPlayerView: View {
    
    @State private var text: String = ""
    @State private var isTyping: Bool = false
    
    var body: some View {
        ZStack {
            bottomStory()
            topStory()
            
            VStack {
                Spacer()
                if isTyping || !text.isEmpty {
                    HStack(spacing: 10) {
                        TextField("", text: $text, prompt: Text("Send message")
                            .bold())
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray3))
                            .clipShape(Capsule())
                            .onTapGesture {
                                withAnimation {
                                    isTyping = true
                                }
                            }
                        
                        Button {
                            isTyping = false
                            text = ""
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
                            TextField("", text: $text, prompt: Text("Send message")
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
                                        isTyping = true
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
            .animation(.bouncy, value: isTyping)
        }
    }
    
    /// Bottom Story
    private func bottomStory() -> some View {
        VStack {
            Rectangle()
                .frame(maxWidth: .infinity)
                .foregroundStyle(.gray)
                .clipShape(
                    .rect(cornerRadius: 10)
                )
                .padding(.bottom, 50)
            Spacer()
        }
    }
    
    /// Top Story
    private func topStory() -> some View {
        VStack(spacing: 15) {
            topBarTimer()
            HStack {
                Circle()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.white)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Doan Van Khoan")
                            .fontWeight(.bold)
                        Text("16h")
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
        Rectangle()
            .frame(maxWidth: .infinity)
            .frame(height: 2)
            .foregroundStyle(.gray)
            .clipShape(Capsule())
            .padding(.horizontal, 5)
            .overlay(alignment: .leading) {
                Rectangle()
                    .frame(width: 200, height: 2)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                    .padding(.horizontal, 5)
            }
    }
}

#Preview {
    StoryPlayerView()
}
