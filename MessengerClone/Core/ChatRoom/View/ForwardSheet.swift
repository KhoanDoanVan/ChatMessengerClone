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
                    if !viewModel.listChannel.isEmpty {
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
            .onAppear {
                viewModel.fetchChannels()
            }
        }
    }
    
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
        ForwardSheet(.stubMessageText, .placeholder)
    }
}
