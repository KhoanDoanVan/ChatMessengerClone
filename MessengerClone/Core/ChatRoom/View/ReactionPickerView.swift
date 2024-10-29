//
//  ReactionPickerView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 10/9/24.
//

import SwiftUI


// MARK: Main View
struct ReactionPickerView: View {
    
    @State private var scaleEmojis: Bool = false
    @StateObject var reactionPickerMenuViewModel: ReactionPickerMenuViewModel
    
    @State private var isShowMore: Bool = false
    
    let message: MessageItem
    let actionHandler: (_ action: ReactionPickerView.ReactionAction) -> Void
    
    var body: some View {
        HStack {
            ForEach(Array(reactionPickerMenuViewModel.emojis.enumerated()), id: \.offset) { index, emoji in
                emojiButton(emoji.reaction.emoji, index: index)
            }
            moreButton()
        }
        .padding(8)
        .background(Color(.systemGray5))
        .clipShape(Capsule())
        .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 0)
        .scaleEffect(scaleEmojis ? 1 : 0.01, anchor: message.direction == .received ? .bottomLeading : .bottomTrailing)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring) {
                    scaleEmojis.toggle()
                }
            }
        }
        .sheet(isPresented: $isShowMore) {
            
        }
    }
    
    /// Emoji
    private func emojiButton(_ emojiString: String, index: Int) -> some View {
        Button {
            reactionPickerMenuViewModel.reactionMessage(emojiString)
            actionHandler(.reaction)
        } label: {
            Text(emojiString)
                .font(.system(size: 32))
                .scaleEffect(reactionPickerMenuViewModel.emojis[index].isAnimating ? 1 : 0.01)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation {
                            reactionPickerMenuViewModel.emojis[index].isAnimating = true
                        }
                    }
                }
        }
    }
    
    /// More
    private func moreButton() -> some View {
        Button {
            actionHandler(.moreReaction)
        } label: {
            Image(systemName: "plus")
                .bold()
                .foregroundStyle(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color(.systemGray3))
                .clipShape(Circle())
        }
    }
}

extension ReactionPickerView {
    enum ReactionAction {
        case reaction
        case moreReaction
    }
}

#Preview {
    ReactionPickerView(reactionPickerMenuViewModel: ReactionPickerMenuViewModel(message: .stubMessageAudio, channel: .placeholder), message: .stubMessageText) { action in
        
    }
}
