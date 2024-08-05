//
//  StoryView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 4/8/24.
//

import SwiftUI

struct StoryScreen: View {
    
    let actionHandler: () -> Void
    
    var items = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
    ]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: items, spacing: 10) {
                ForEach(0..<12) { _ in
                    StoryCellView() {
                        actionHandler()
                    }
                }
            }
        }
        .padding(.top)
    }
}

#Preview {
    StoryScreen() {
        
    }
}
