//
//  GroupChatPickerView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 9/8/24.
//

import SwiftUI

struct GroupChatPickerView: View {
    @Environment(\.dismiss) private var dismiss
    
    var onCreate: (_ newChannel: ChannelItem) -> Void
        
    
    @State private var nameGroup: String = ""
    @State private var writingState: Bool = false
    @State private var scaleAnimationCancel = 1.0
        
    @ObservedObject var viewModel: GroupChatPickerViewModel
    
    var isEmptySearch: Bool {
        return viewModel.search.isEmpty
    }
    
    var body: some View {
        ZStack {
            VStack {
                nameGroupTextField()
                    .padding(.top, 10)
                searchCustom()
                    .offset(writingState ? CGSize(width: 0, height: -30) : CGSize(width: 0, height: 0))
                
                if viewModel.showPickerList {
                    listPicked()
                }
                
                listSuggested()
            }
            .opacity(writingState ? 0 : 1)
            
            if writingState {
                viewSearch()
            }
        }
        .onChange(of: viewModel.search) {
            viewModel.searchUserPicker()
        }
        .navigationTitle("New group")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            cancelButton()
            createButton()
        }
        .animation(.easeInOut, value: viewModel.showPickerList)
        .animation(.bouncy, value: writingState)
    }
    
    /// View searching
    private func viewSearch() -> some View {
        VStack {
            searchCustom()
                .offset(writingState ? CGSize(width: 0, height: 0) : CGSize(width: 0, height: -30))
                .padding(.top, 10)
            List {
                Section {
                    ForEach(viewModel.listUserSearch) { user in
                        ChatPartnerRowView(user: user, viewModel: viewModel)
                            .listRowBackground(Color(.messagesGray))
                    }
                }
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .background(.messagesGray)
        .opacity(writingState ? 1 : 0)
    }
    
    /// List picked
    private func listPicked() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(viewModel.usersPicker) { user in
                    VStack {
                        CircularProfileImage(size: .custom(70))
                            .overlay(alignment: .topTrailing) {
                                Circle()
                                    .frame(width: 25, height: 25)
                                    .overlay {
                                        Button {
                                            viewModel.removeUserPicker(user)
                                        } label: {
                                            Image(systemName: "xmark")
                                                .font(.footnote)
                                                .foregroundStyle(.white)
                                                .bold()
                                        }
                                    }
                                    .foregroundStyle(Color(.systemGray3))
                            }
                        Text(user.username)
                    }
                    .padding(.leading, 15)
                }
            }
        }
        .padding(.top)
    }
    
    /// List suggest
    private func listSuggested() -> some View {
        List {
            Section {
                ForEach(viewModel.users) { user in
                    ChatPartnerRowView(user: user, viewModel: viewModel)
                }
            } header: {
                Text("Suggested")
                    .textCase(nil)
            }
            
            /// Progress for fetchMoreUsers
            if viewModel.isPagination {
                progressLoadMore()
            }
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
    }
    
    /// Progress for pagination
    private func progressLoadMore() -> some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .task {
                await viewModel.fetchUsers()
            }
    }
    
    /// Name group
    private func nameGroupTextField() -> some View {
        TextField("", text: $nameGroup, prompt: Text("Group name (optinal)"))
            .opacity(writingState ? 0 : 1)
            .animation(.easeInOut, value: writingState)
            .padding(.horizontal, 15)
    }
    
    /// Search Bar
    private func searchCustom() -> some View {
        HStack {
            TextField("", text: $viewModel.search, prompt: Text("Search friend"))
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 30)
                .padding(.vertical, 5)
                .background(Color(.systemGray3))
                .cornerRadius(10)
                .overlay {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color(.systemGray))
                        Spacer()
                        if !isEmptySearch {
                            Button {
                                viewModel.search = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(Color(.systemGray))
                            }
                        }
                    }
                    .padding(.horizontal, 5)
                }
                .onTapGesture {
                    scaleAnimationCancel = 1
                    writingState = true
                }
            
            if writingState {
                Button("Cancel") {
                    scaleAnimationCancel = 0
                    writingState = false
                }
                .scaleEffect(scaleAnimationCancel)
                .animation(.linear(duration: 1), value: writingState)
                .opacity(writingState ? 1 : 0)
            }
        }
        .animation(.bouncy, value: writingState)
        .padding(.horizontal, 10)
    }
}

extension GroupChatPickerView {
    @ToolbarContentBuilder
    private func cancelButton() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Cancel") {
                dismiss()
            }
        }
    }
    
    @ToolbarContentBuilder
    private func createButton() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Create") {
                if viewModel.isDirectChannel {
                    guard let chatPartner = viewModel.usersPicker.first else { return }
                    viewModel.createDirectChannel(chatPartner, completion: onCreate)
                } else {
                    viewModel.createGroupChannel(nameGroup, completion: onCreate)
                }
            }
            .disabled(viewModel.disableDone)
        }
    }
}

#Preview {
    NavigationStack {
        GroupChatPickerView(onCreate: {newChannel in }, viewModel: GroupChatPickerViewModel())
    }
}
