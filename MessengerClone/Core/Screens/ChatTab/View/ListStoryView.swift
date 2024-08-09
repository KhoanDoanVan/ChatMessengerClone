//
//  ListStoryView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 24/7/24.
//

import SwiftUI

struct ListStoryView: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach(0..<12) { _ in
                    StoryItemView(isStory: true, isOnline: true)
                }
            }
        }
        .padding(.top)
        .listRowInsets(EdgeInsets())
    }
}

#Preview {
    ListStoryView()
}
