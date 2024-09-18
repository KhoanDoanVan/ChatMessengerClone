//
//  CreateChatView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 30/7/24.
//

import SwiftUI

struct CreateChatView: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = GroupChatPickerViewModel()
    
    @State private var search: String = ""
    var onCreate: (_ newChannel: ChannelItem) -> Void
    
    var body: some View {
        NavigationStack(path: $viewModel.navRoutes) {
            VStack {
                List {
                    Section {
                        Section {
                            ForEach(CreateChatViewOption.allCases) { item in
                                buttonChoice(item: item) {
                                    guard item == CreateChatViewOption.newGroup else { return }
                                    viewModel.navRoutes.append(.groupChat)
                                }
                                .listRowSeparator(.hidden)
                            }
                        }
                        
                        Section {
                            ForEach(viewModel.users) { user in
                                rowUserPickerDirectChannel(user: user)
                                    .onTapGesture {
                                        viewModel.createDirectChannel(user, completion: onCreate)
                                    }
                            }
                        } header: {
                            Text("Suggested")
                                .fontWeight(.bold)
                                .foregroundStyle(Color(.systemGray))
                        }
                    } header: {
                        searchBar()
                            .listRowInsets(EdgeInsets())
                            .padding(.horizontal, 25)
                            .background(Color(.systemGray6))
                    }
                    
                    /// Progress for fetchMoreUsers
                    if viewModel.isPagination {
                        progressLoadMore()
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("New message")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ChannelCreateRoute.self, destination: { route in
                destinationView(for: route)
            })
            .toolbar {
                buttonLeading()
            }
        }
    }
    
    private func progressLoadMore() -> some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .task {
                await viewModel.fetchUsers()
            }
    }
}

extension CreateChatView {
    
    private struct buttonChoice: View {
        
        let item: CreateChatViewOption
        let onTapHandler: () -> Void
        
        var body: some View {
            Button {
                onTapHandler()
            } label: {
                buttonBody()
            }
        }
        
        private func buttonBody() -> some View {
            HStack(spacing: 10) {
                Image(systemName: item.icon)
                    .frame(width: 30, height: 30)
                    .padding(5)
                    .foregroundStyle(.messagesBlack)
                    .background(Color(.systemGray))
                    .clipShape(Circle())
                
                Text(item.title)
                    .fontWeight(.bold)
            }
        }
    }
    
    private func rowUserPickerDirectChannel(user: UserItem) -> some View {
        HStack {
            CircularProfileImage(size: .custom(65))
            Text(user.username)
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: ChannelCreateRoute) -> some View {
        switch route {
        case .groupChat:
            GroupChatPickerView(onCreate: onCreate, viewModel: viewModel)
        }
    }
    
    @ToolbarContentBuilder
    private func buttonLeading() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                dismiss()
            } label: {
                Text("Cancel")
            }
        }
    }
    
    @ViewBuilder
    private func searchBar() -> some View {
        HStack {
            Text("To:")
            TextField(text: $search) {
                
            }
            .font(.system(size: 18))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40)
    }
}


enum CreateChatViewOption: String, CaseIterable, Identifiable {
    case newGroup = "Create a new group"
    case community = "Community"
    
    var id: String {
        return rawValue
    }
    
    var title: String {
        return rawValue
    }
    
    var icon: String {
        switch self {
        case .newGroup:
            return "person.3.fill"
        case .community:
            return "message.fill"
        }
    }
}

#Preview {
    NavigationStack {
        CreateChatView() {newChannel in 
            
        }
    }
}
