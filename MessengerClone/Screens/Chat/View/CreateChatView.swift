//
//  CreateChatView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 30/7/24.
//

import SwiftUI

struct CreateChatView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var search: String
    
    var body: some View {
        VStack {
            List {
                Section {
                    Section {
                        Text("Create a new group")
                        Text("Community")
                    }
                    
                    Section {
                        ForEach(0..<12) { _ in
                            HStack {
                                Circle()
                                    .frame(width: 65, height: 65)
                                Text("User name")
                            }
                        }
                    } header: {
                        Text("Suggested")
                    }
    
                } header: {
                    searchBar()
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
}

extension CreateChatView {
    @ViewBuilder
    private func searchBar() -> some View {
        HStack {
            Text("To:")
            TextField(text: $search) {
                
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40)
    }
}

#Preview {
    NavigationStack {
        CreateChatView(search: .constant(""))
    }
}
