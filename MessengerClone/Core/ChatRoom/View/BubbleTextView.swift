//
//  BubbleTextView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 9/8/24.
//

import SwiftUI

struct BubbleTextView: View {
    var body: some View {
        HStack {
            Text("BubbleTextView")
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(.messagesBlack)
                .foregroundStyle(.messagesWhite)
                .clipShape(
                    .rect(
                        cornerRadii: 
                                .init(
                                    topLeading: 10,
                                    bottomLeading: 10,
                                    bottomTrailing: 20, topTrailing: 20
                                )
                    )
                )
        }
    }
}

#Preview {
    BubbleTextView()
}
