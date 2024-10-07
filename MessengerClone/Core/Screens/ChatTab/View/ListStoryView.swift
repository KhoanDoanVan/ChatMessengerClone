//
//  ListStoryView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 24/7/24.
//

import SwiftUI

struct ListNoteView: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                NoteCellView(isOnline: .constant(false), isUserCurrent: .constant(true), noteText: .constant("Your note"))
                ForEach(0..<12) { _ in
                    NoteCellView(isOnline: .constant(true), isUserCurrent: .constant(false), noteText: .constant("Hello ca nha"))
                }
            }
        }
        .listRowInsets(EdgeInsets())
    }
}

#Preview {
    ListNoteView()
}
