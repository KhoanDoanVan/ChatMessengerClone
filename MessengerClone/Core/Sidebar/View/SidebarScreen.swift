//
//  SidebarScreen.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 6/8/24.
//

import SwiftUI

struct SidebarScreen: View {
    var body: some View {
        VStack {
            Text("Dwd")
        }
        .frame(width: (UIWindowScene.current?.screenWidth ?? 0) - 50)
        .frame(maxHeight: .infinity)
        .background(.messagesGray)
    }
}

#Preview {
    SidebarScreen()
}
