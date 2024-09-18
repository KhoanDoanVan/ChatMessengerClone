//
//  MenuPickerView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 10/9/24.
//

import SwiftUI

struct MenuPickerView: View {
    
    @State private var scaleMenu: Bool = false
    
    let message: MessageItem
    @StateObject var reactionPickerMenuViewModel: ReactionPickerMenuViewModel
    
    var body: some View {
        VStack {
            VStack {
                ForEach(MenuAction.allCases) { action in
                    VStack {
                        actionMenu(action)
                        if action != MenuAction.unsend {
                            Divider()
                                .padding(0)
                        }
                    }
                    .padding(0)
                }
            }
            .background(Color(.systemGray5))
            .clipShape(
                .rect(
                    cornerRadii: .init(
                        topLeading: 15,
                        topTrailing: 15
                    )
                )
            )
            
            Button {
                
            } label: {
                HStack {
                    Text("More")
                    Spacer()
                    Image(systemName: "ellipsis.circle")
                }
                .bold()
                .foregroundStyle(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color(.systemGray5))
                .clipShape(
                    .rect(
                        cornerRadii: .init(
                            bottomLeading: 15,
                            bottomTrailing: 15
                        )
                    )
                )
            }
        }
        .frame(width: 250)
        .ignoresSafeArea()
        .scaleEffect(scaleMenu ? 1 : 0.01, anchor: message.direction == .received ? .topLeading : .topTrailing)
        .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 0)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation (.spring){
                    scaleMenu.toggle()
                }
            }
        }
    }
    
    private func actionMenu(_ action: MenuAction) -> some View {
        Button {
            
        } label: {
            HStack {
                Text(action.title)
                Spacer()
                Image(systemName: action.icon)
            }
            .bold()
            .foregroundStyle(action.color)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
        }
    }
}

extension MenuPickerView {
    enum MenuAction: String, Identifiable, CaseIterable {
        case reply, save, forward, unsend
        
        var id: String {
            return rawValue
        }
        
        var title: String {
            return rawValue.capitalized
        }
        
        var icon: String {
            switch self {
            case .reply:
                return "arrowshape.turn.up.backward.fill"
            case .save:
                return "arrow.down.to.line"
            case .forward:
                return "arrowshape.turn.up.forward.fill"
            case .unsend:
                return "trash.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .unsend:
                return Color(.red)
            default:
                return .white
            }
        }
    }
}

#Preview {
    MenuPickerView(message: .stubMessageAudio, reactionPickerMenuViewModel: ReactionPickerMenuViewModel(message: .stubMessageAudio, channel: .placeholder))
}
