//
//  ChatPartnerRowView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 9/8/24.
//

import SwiftUI

struct ChatPartnerRowView: View {

    let user: UserItem
    @ObservedObject var viewModel: GroupChatPickerViewModel
    
    var body: some View {
        Button {
            viewModel.handleActionPickerUser(user)
        } label: {
            HStack {
                CircularProfileImage(size: .custom(70))
                
                Text(user.username)
                    .foregroundStyle(.messagesBlack)
                    .bold()
                Spacer()
                Image(systemName: viewModel.isPickerCheck(user) ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(viewModel.isPickerCheck(user) ? Color(.systemBlue) : Color(.systemGray))
            }
        }
        .animation(.bouncy, value: viewModel.isPickerCheck(user))
    }
}

#Preview {
    ChatPartnerRowView(user: .placeholder, viewModel: GroupChatPickerViewModel())
}
