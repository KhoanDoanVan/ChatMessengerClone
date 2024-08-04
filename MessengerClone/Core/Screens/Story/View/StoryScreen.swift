//
//  StoryView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 4/8/24.
//

import SwiftUI

struct StoryScreen: View {
    
    private var items = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
    ]
    
    private var widthOfStory: CGFloat {
        return ((UIWindowScene.current?.screenWidth ?? 0) / 2) - 10
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: items, spacing: 10) {
                ForEach(0..<12) { _ in
                    Rectangle()
                        .frame(width: widthOfStory, height: 250)
                        .cornerRadius(20)
                }
            }
        }
        .padding(.top)
    }
}

#Preview {
    StoryScreen()
}
