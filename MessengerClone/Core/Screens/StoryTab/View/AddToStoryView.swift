//
//  AddToStoryView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 5/8/24.
//

import SwiftUI

struct AddToStoryView: View {
    @Environment(\.dismiss) private var dismiss

    var items = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                LazyVGrid(columns: items, spacing: 10) {
                    ForEach(StoryType.allCases) { type in
                        ButtonTypeStoryView(type)
                    }
                }
                .padding(.top)
                
                Spacer()
            }
            .toolbar {
                titleNavigation()
                trailingButton()
                leadingButton()
            }
            .toolbarTitleDisplayMode(.inline)
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
