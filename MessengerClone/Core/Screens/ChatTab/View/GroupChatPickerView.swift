//
//  GroupChatPickerView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 9/8/24.
//

import SwiftUI

struct GroupChatPickerView: View {
    @Environment(\.dismiss) private var dismiss
        
    @State private var search: String = ""
    @State private var nameGroup: String = ""
    
    var isEmptySearch: Bool {
        return search.isEmpty
    }
    
    @State private var writingState: Bool = false
    
    var body: some View {
        VStack {
            nameGroupTextField()
            searchCustom()
            
            listPicked()
            
            listSuggested()
        }
        .navigationTitle("New group")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            cancelButton()
            createButton()
        }
    }
    
    private func listPicked() -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(0..<3) { _ in
                    VStack {
                        Circle()
                            .frame(width: 70, height: 70)
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    
                                } label: {
                                    Circle()
                                        .frame(width: 25, height: 25)
                                        .overlay {
                                            Image(systemName: "xmark")
                                                .font(.footnote)
                                                .foregroundStyle(.white)
                                                .bold()
                                        }
                                        .foregroundStyle(Color(.systemGray3))
                                }
                            }
                        Text("User name")
                    }
                    .padding(.leading, 15)
                }
            }
        }
        .padding(.top)
    }
    
    private func listSuggested() -> some View {
        List {
            Section {
                ForEach(0..<12) { _ in
                    ChatPartnerRowView()
                }
            } header: {
                Text("Suggested")
                    .textCase(nil)
            }
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
    }
    
    private func nameGroupTextField() -> some View {
        TextField("", text: $nameGroup, prompt: Text("Group name (ptional)"))
            .opacity(writingState ? 0 : 1)
            .animation(.easeInOut, value: writingState)
            .padding(.horizontal, 15)
    }
    
    private func searchCustom() -> some View {
        HStack {
            TextField("", text: $search)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 30)
                .padding(.vertical, 5)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .overlay {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color(.systemGray))
                        Spacer()
                        if !isEmptySearch {
                            Button {
                                search = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(Color(.systemGray))
                            }
                        }
                    }
                    .padding(.horizontal, 5)
                }
                .onTapGesture {
                    writingState = true
                }
            
            if writingState {
                Button("Cancel") {
                    writingState = false
                }
                .opacity(writingState ? 1 : 0)
            }
        }
        .offset(writingState ? CGSize(width: 0, height: -30) : CGSize(width: 0, height: 0))
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
            }
        }
    }
}

#Preview {
    NavigationStack {
        GroupChatPickerView()
    }
}
