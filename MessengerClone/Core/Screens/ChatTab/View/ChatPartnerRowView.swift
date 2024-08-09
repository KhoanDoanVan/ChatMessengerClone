//
//  ChatPartnerRowView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 9/8/24.
//

import SwiftUI

struct ChatPartnerRowView: View {
    
    @State private var picked: Bool = false
    
    var body: some View {
        Button {
            picked.toggle()
        } label: {
            HStack {
                Circle()
                    .frame(width: 70, height: 70)
                    .foregroundStyle(.messagesBlack)
                Text("User name")
                    .foregroundStyle(.messagesBlack)
                    .bold()
                Spacer()
                Image(systemName: picked ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(picked ? Color(.systemBlue) : Color(.systemGray))
            }
        }
        .animation(.bouncy, value: picked)
    }
}

#Preview {
    ChatPartnerRowView()
}
