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
    
    init(_ messageForward: MessageItem, _ currentUser: UserItem, currentChannel: ChannelItem) {
        self._viewModel = StateObject(wrappedValue: ForwardSheetViewModel(messageForward: messageForward, currentUser, currentChannel))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    if !viewModel.listChannel.isEmpty {
                        ForEach(viewModel.listChannel, id: \.self) { channel in
                            HStack {
                                
                                if channel.channel.isGroupChat {
                                    CircularProfileImage(channel.channel, size: .small)
                                } else {
                                    CircularProfileImage(channel.channel.coverImageUrl ,size: .small)
                                }
                                
                                Text("\(channel.channel.title)")
                                    .bold()
                                
                                Spacer()
                                
                                Button {
                                    viewModel.actionSendMessage(channel)
                                } label: {
                                    Rectangle()
                                        .frame(width: 60, height: 30)
                                        .foregroundStyle(Color(.systemGray5))
                                        .clipShape(
                                            .rect(cornerRadius: 20)
                                        )
                                        .overlay(alignment: .center) {
                                            switch channel.state {
                                            case .waiting:
                                                Text("Send")
                                                    .font(.footnote)
                                                    .foregroundStyle(.white)
                                                    .bold()
                                            case .sent:
                                                Text("Unsend")
                                                    .font(.footnote)
                                                    .foregroundStyle(.white)
                                                    .bold()
                                            case .sending:
                                                ProgressView()
                                            }
                                        }
                                }
                            }
                        }
                    } else {
                        ProgressView()
                    }
                    
                    if !viewModel.listUser.isEmpty {
                        ForEach(viewModel.listUser, id: \.self) { user in
                            HStack {
                                
                                CircularProfileImage(user.profileImage, size: .small)
                                
                                Text("\(user.username)")
                                    .bold()
                                
                                Spacer()
                                
                                Button {
                                    
                                } label: {
                                    Text(viewModel.isSent ? "Unsent" : "Send")
                                        .bold()
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 5)
                                        .background(Color(.systemGray5))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    } else {
                        ProgressView()
                    }
                    
                    if viewModel.pagination {
                        loadingMoreUsers()
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
    
    /// Loading more users view
    private func loadingMoreUsers() -> some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .onAppear {
                Task {
                    try await viewModel.fetchUsers()
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
        ForwardSheet(.stubMessageText, .placeholder, currentChannel: .placeholder)
    }
}
