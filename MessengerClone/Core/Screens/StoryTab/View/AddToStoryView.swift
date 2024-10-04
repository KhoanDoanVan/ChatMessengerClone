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
    
    let handleAction: () -> Void
    
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
                StoryBoardNewView(uiImage: viewModel.uiImagePicker) { action in
                    switch action {
                    case .addToStory:
                        handleAction()
                        viewModel.isShowStoryBoard = false
                    case .back:
                        viewModel.isShowStoryBoard = false
                    }
                }
            }
            .fullScreenCover(isPresented: $viewModel.isShowCameraCapture) {
                CameraCaptureStoryView() {
                    viewModel.isShowCameraCapture = false
                }
            }
        }
    }
    
    /// Cell Attachment
    private func cellAttachment(_ attachment: MediaAttachment) -> some View {
        Button {
            viewModel.uiImagePicker = attachment.thumbnail
            viewModel.isShowStoryBoard = true
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
            ForEach(StoryChooseType.allCases) { type in
                ButtonTypeStoryView(type)
                    .onTapGesture {
                        if type == .camera {
                            DispatchQueue.global(qos: .background).async {
                                viewModel.isShowCameraCapture = true
                            }
                        }
                        if type == .text {
                            viewModel.isShowStoryBoard.toggle()
                        }
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

enum AddToStoryAction {
    case addToStory
    case back
}

enum StoryChooseType: String, CaseIterable, Identifiable {
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
        AddToStoryView() {
            
        }
    }
}
