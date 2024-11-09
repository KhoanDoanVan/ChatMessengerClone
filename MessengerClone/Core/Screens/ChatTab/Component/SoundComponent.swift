//
//  SoundComponent.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 9/11/24.
//

import SwiftUI

enum SizeSoundComponent {
    case mini
    case medium
}

struct SoundComponent: View {
        
    @State private var rect1Height: CGFloat = 4
    @State private var rect2Height: CGFloat = 3
    @State private var rect3Height: CGFloat = 4
    
    var size: SizeSoundComponent
    
    init(size: SizeSoundComponent) {
        self.size = size
        switch size {
        case .mini:
            rect1Height = 4
            rect2Height = 4
            rect3Height = 4
        case .medium:
            rect1Height = 4
            rect2Height = 3
            rect3Height = 4
        }
    }
    
    var body: some View {
        HStack(spacing: 2) {
            Rectangle()
                .frame(width: 2, height: rect1Height)
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                        rect1Height = size == .medium ? 6 : 4
                    }
                }
            Rectangle()
                .frame(width: 2, height: rect2Height)
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                            rect2Height = size == .medium ? 12 : 7
                        }
                    }
                }
            Rectangle()
                .frame(width: 2, height: rect3Height)
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                        rect3Height = size == .medium ? 6 : 4
                    }
                }
        }
    }
}

#Preview(body: {
    SoundComponent(size: .medium)
})
