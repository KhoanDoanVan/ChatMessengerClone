//
//  TextFieldAuthModifier.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 13/8/24.
//

import SwiftUI

struct TextFieldAuthModifier: ViewModifier {
    
    let cornerRadii: RectangleCornerRadii = .init(
        topLeading: 10, bottomLeading: 10, bottomTrailing: 10, topTrailing: 10
    )
    
    func body(content: Content) -> some View {
        content
            .padding(10)
            .background(Color(.systemGray6))
            .clipShape(
                .rect(
                    cornerRadii: cornerRadii
                )
            )
            .padding(.horizontal, 15)
    }
}
