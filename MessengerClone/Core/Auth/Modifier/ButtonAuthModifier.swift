//
//  ButtonAuthModifier.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 13/8/24.
//

import SwiftUI

struct ButtonAuthModifier: ViewModifier {
    
    let rectangleCornerRadii: RectangleCornerRadii = .init(
        topLeading: 10, bottomLeading: 10, bottomTrailing: 10, topTrailing: 10
    )
    
    func body(content: Content) -> some View {
        content
            .bold()
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .clipShape(
                .rect(cornerRadii: rectangleCornerRadii)
            )
            .padding(.horizontal, 15)
    }
}
