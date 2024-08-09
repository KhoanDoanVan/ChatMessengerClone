//
//  CreateChatView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 30/7/24.
//

import SwiftUI

struct CreateChatView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var search: String = ""
    let onCreate: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section {
                        Section {
                            ForEach(CreateChatViewOption.allCases) { item in
                                buttonChoice(item: item)
                                    .listRowSeparator(.hidden)
                            }
                        }
                        
                        Section {
                            ForEach(0..<12) { _ in
                                Button {
                                    onCreate()
                                } label: {
                                    HStack {
                                        Circle()
                                            .frame(width: 65, height: 65)
                                        Text("User name")
                                    }
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
                }
                .listStyle(.plain)
            }
            .navigationTitle("New message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                buttonLeading()
            }
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

extension CreateChatView {
    
    private struct buttonChoice: View {
        
        let item: CreateChatViewOption
        
        var body: some View {
            NavigationLink {
                GroupChatPickerView()
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
        CreateChatView() {
            
        }
    }
}
