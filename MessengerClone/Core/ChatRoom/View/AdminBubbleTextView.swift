//
//  AdminBubbleTextView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 17/8/24.
//

import SwiftUI

struct AdminBubbleTextView: View {
    
    let channel: ChannelItem
    
    var body: some View {
        VStack {
            CircularProfileImage(channel, size: .xLarge)
            
            Text("Cool People")
                .font(.title)
                .bold()
            
            Text("You created this group")
                .opacity(0.7)
                .bold()
            HStack(spacing: 20) {
                ForEach(GroupActionCreated.allCases) { action in
                    buttonActionCreated(action)
                }
            }
            Text("You named the group Cool People")
                .bold()
                .opacity(0.7)

        }
    }
    
    private func buttonActionCreated(_ action: GroupActionCreated) -> some View {
        Button {
            
        } label: {
            VStack {
                Image(systemName: action.icon)
                    .frame(width: 30, height: 30)
                    .padding(8)
                    .background(.messagesGray)
                    .font(.title3)
                    .clipShape(Circle())
                    .bold()
                    .foregroundStyle(.messagesBlack)
                Text(action.title)
                    .font(.footnote)
                    .bold()
                    .foregroundStyle(.messagesBlack)
            }
        }
        .frame(width: 60, height: 60)
    }
}

enum GroupActionCreated:String, Identifiable, CaseIterable {
    case add, name, members
    
    var id: String {
        return self.rawValue
    }
    
    var title: String {
        switch self {
        case .add:
            return "Add"
        case .name:
            return "Name"
        case .members:
            return "Members"
        }
    }
    
    var icon: String {
        switch self {
        case .add:
            return "person.fill.badge.plus"
        case .name:
            return "pencil"
        case .members:
            return "person.3.fill"
        }
    }
}

#Preview {
    AdminBubbleTextView(channel: .placeholder)
}
