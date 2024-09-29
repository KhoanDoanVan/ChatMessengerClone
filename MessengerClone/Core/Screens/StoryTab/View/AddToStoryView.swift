//
//  AddToStoryView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 5/8/24.
//

import SwiftUI

struct AddToStoryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddToStoryViewModel()

    var selections = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
    ]
    
    var columnItems = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(),  spacing: 2),
        GridItem(.flexible()),
    ]
    
    let widthImage = ((UIWindowScene.current?.screenWidth ?? 0) - 4) / 3
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                topSelect()
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: columnItems, spacing: 2) {
                        ForEach(viewModel.listMediaAttachment, id: \.self) { attachment in
                            cellAttachment(attachment)
                        }
                    }
                }
                .padding(.top)
            }
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                titleNavigation()
                trailingButton()
                leadingButton()
            }
            .fullScreenCover(isPresented: $viewModel.isShowStoryBoard) {
                StoryBoardNewView() {
                    viewModel.isShowStoryBoard = false
                }
            }
        }
    }
    
    /// Cell Attachment
    private func cellAttachment(_ attachment: MediaAttachment) -> some View {
        Button {
            
        } label: {
            Image(uiImage: attachment.thumbnail)
                .resizable()
                .frame(width: widthImage)
                .frame(height: widthImage)
                .scaledToFill()
        }
    }
    
    /// Top Select Box
    private func topSelect() -> some View {
        HStack {
            ForEach(StoryType.allCases) { type in
                ButtonTypeStoryView(type)
                    .onTapGesture {
                        viewModel.isShowStoryBoard.toggle()
                    }
            }
        }
    }
}

extension AddToStoryView {
    @ToolbarContentBuilder
    private func titleNavigation() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack {
                Text("Add to story")
                    .fontWeight(.bold)
                Text("Recents")
                    .font(.footnote)
            }
        }
    }
    
    @ToolbarContentBuilder
    private func leadingButton() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                dismiss()
            } label: {
                Text("Cancel")
                    .foregroundStyle(.messagesBlack)
            }
        }
    }
    
    @ToolbarContentBuilder
    private func trailingButton() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                
            } label: {
                Text("Albums")
                    .foregroundStyle(.messagesBlack)
            }
        }
    }
}

enum StoryType: String, CaseIterable, Identifiable {
    case camera
    case text
    
    var id: String {
        return rawValue
    }
    
    var title: String {
        switch self {
        case .camera:
            return "Camera"
        case .text:
            return "Text"
        }
    }
    
    var icon: String {
        switch self {
        case .camera:
            return "camera.fill"
        case .text:
            return "textformat"
        }
    }
}

#Preview {
    NavigationStack {
        AddToStoryView()
    }
}
