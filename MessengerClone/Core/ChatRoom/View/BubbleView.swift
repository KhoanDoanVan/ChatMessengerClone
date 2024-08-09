//
//  BubbleView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 9/8/24.
//

import SwiftUI

struct BubbleView: View {
    var body: some View {
        VStack {
            composeDynamicBubbleView()
            composeDynamicBubbleView()
            composeDynamicBubbleView()
        }
        .frame(maxWidth: .infinity)
    }
    
    private func composeDynamicBubbleView() -> some View {
        BubbleTextView()
    }
}

#Preview {
    BubbleView()
}
