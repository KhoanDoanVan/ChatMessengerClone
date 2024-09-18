//
//  ReactionShowSheetView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 15/9/24.
//

import SwiftUI


struct ReactionShowSheetView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: ReactionShowSheetViewModel
    let message: MessageItem
    let channel: ChannelItem
    
    init(message: MessageItem, channel: ChannelItem) {
        self.message = message
        self.channel = channel
        _viewModel = StateObject(wrappedValue: ReactionShowSheetViewModel(message: message, channel: channel))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView(.vertical) {
                    ForEach(viewModel.listReactions, id: \.self) { reactionItem in
                        rowReaction(reactionItem)
                    }
                }
            }
            .padding()
            .navigationTitle("Reactions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                dismissButton()
            }
        }
    }
    
    /// Row
    private func rowReaction(_ reactionItem: ReactionItem) -> some View {
        HStack {
            CircularProfileImage(reactionItem.senderReaction?.profileImage, size: .small)
            
            VStack(alignment: .leading) {
                Text(reactionItem.senderReaction?.username ?? "")
                    .bold()
                
                if reactionItem.senderReaction?.uid == viewModel.currentUserUid {
                    Text("Tap to remove")
                        .font(.footnote)
                }
            }
            
            Spacer()
            
            Text(reactionItem.reaction)
                .font(.title)
        }
        .onTapGesture {
            if reactionItem.senderReaction?.uid == viewModel.currentUserUid {
                viewModel.tapToRemoveReaction(reactionItem)
                dismiss()
            }
        }
    }
    
    /// Dismiss button
    private func dismissButton() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(.white)
                    .font(.footnote)
                    .bold()
                    .padding(8)
                    .background(Color(.systemGray2))
                    .clipShape(Circle())
            }
        }
    }
}

#Preview {
    NavigationStack {
        ReactionShowSheetView(message: .stubMessageText, channel: .placeholder)
    }
}
