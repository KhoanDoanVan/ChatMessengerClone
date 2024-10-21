//
//  ForwardSheet.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 21/10/24.
//

import SwiftUI
import Kingfisher

struct ForwardSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: ForwardSheetViewModel
    
    init(_ messageForward: MessageItem, _ currentUser: UserItem) {
        self._viewModel = StateObject(wrappedValue: ForwardSheetViewModel(messageForward: messageForward, currentUser))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(viewModel.listChannel, id: \.self) { channel in
                        HStack {
                            
                            if channel.isGroupChat {
                                CircularProfileImage(channel, size: .small)
                            } else {
                                CircularProfileImage(channel.coverImageUrl ,size: .small)
                            }
                            
                            Text("\(channel.title)")
                                .bold()
                            
                            Spacer()
                            
                            Button {
                                viewModel.isSent.toggle()
                            } label: {
                                Text(viewModel.isSent ? "Send" : "Unsent")
                                    .bold()
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 5)
                                    .background(Color(.systemGray5))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .listStyle(.inset)
            }
            .searchable(text: $viewModel.searchable, prompt: "Search")
            .navigationTitle("Send to")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                toolbarLeading
                toolbarTrailing
            }
        }
    }
    
    /// Leading toolbar
    private var toolbarLeading: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Done") {
                dismiss()
            }
        }
    }
    
    /// Trailing toolbar
    private var toolbarTrailing: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Create group") {
                
            }
        }
    }
}

#Preview {
    NavigationStack {
        ForwardSheet(.stubMessageText, .placeholder)
    }
}
