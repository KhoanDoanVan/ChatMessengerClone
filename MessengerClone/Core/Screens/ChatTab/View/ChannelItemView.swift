//
//  ChannelItem.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 24/7/24.
//

import SwiftUI
import FirebaseAuth

class ChannelItemViewModel: ObservableObject {
    @Published var onlineObject: (state: Bool, lastActive: Date?)?
    @Published var currentUserUid: String
    
    init(channel: ChannelItem) {
        self.currentUserUid = Auth.auth().currentUser?.uid ?? ""
        if !channel.isGroupChat {
            let uidPartner = channel.usersChannel[0].id
            TrackingOnlineService.singleStateOnlineUserByIds(uidPartner) { state, lastActive in
                self.onlineObject = (state, lastActive)
            }
        }
    }
}

struct ChannelItemView: View {
    
    let channel: ChannelItem
    @StateObject private var viewModel: ChannelItemViewModel
    
    init(channel: ChannelItem) {
        self.channel = channel
        
        self._viewModel = StateObject(wrappedValue: ChannelItemViewModel(channel: channel))
    }
    
    private var channelPreviewMessage: String {
        let maxChar = 30
        let trailingChars = channel.previewMessage.count > maxChar ? "..." : ""
        let title = String(channel.previewMessage.prefix(maxChar) + trailingChars)
        
        return title
    }
    
    private var channelTitlePreview: String {
        let maxChar = 30
        let trailingChars = channel.title.count > maxChar ? "..." : ""
        let title = String(channel.title.prefix(maxChar) + trailingChars)
        
        return title
    }
    
    var body: some View {
        HStack {
            imageChannel()
            
            VStack(alignment: .leading) {
                Text(channelTitlePreview)
                    .foregroundStyle(.messagesBlack)
                    .fontWeight(.bold)
                HStack(spacing: 0){
                    Text(channelPreviewMessage)
                        .foregroundStyle(channel.seenBy.contains(where: { $0 == viewModel.currentUserUid }) ? .messagesBlack.opacity(0.5) : .white)
                        .onAppear {
                            print("ChannelCheckCurrentUserSeen: \(channel.seenBy.contains(where: { $0 == viewModel.currentUserUid })) with channelSeenBy: \(channel.seenBy) and currentUserUid: \(viewModel.currentUserUid)")
                        }
                    Text(" • \(channel.lastMessageTimestamp.formattedTimeIntervalPreviewChannel())")
                        .foregroundStyle(.messagesBlack.opacity(0.5))
                        .bold(!channel.seenBy.contains(where: { $0 == viewModel.currentUserUid }))
                }
                .font(.subheadline)
            }
        }
    }
    
    @ViewBuilder
    private func imageChannel() -> some View {
        ZStack {
            if channel.isGroupChat {
                CircularProfileImage(channel, size: .xMedium)
            } else {
                CircularProfileImage(channel.coverImageUrl ,size: .xMedium)
            }
            
            if (viewModel.onlineObject?.state ?? false) && !channel.isGroupChat {
                onlineIcon()
            } else if (!(viewModel.onlineObject?.state ?? false)) && !channel.isGroupChat &&  (viewModel.onlineObject?.lastActive?.formattedOnlineChannel() == "second") {
                onlineIcon()
            }
            else if (!(viewModel.onlineObject?.state ?? false)) && !channel.isGroupChat &&  (viewModel.onlineObject?.lastActive?.formattedOnlineChannel() == "") {
                
            } else if (!(viewModel.onlineObject?.state ?? false)) && !channel.isGroupChat {
                if let lastActive = viewModel.onlineObject?.lastActive {
                    timeAgo(lastActive)
                }
            }
        }
        .frame(width: 75, height: 75)
    }
    
    @ViewBuilder
    private func onlineIcon() -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ZStack {
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.messagesWhite)
                    Circle()
                        .frame(width: 15, height: 15)
                        .foregroundStyle(.green)
                }
                .padding(3)
            }
        }
    }
    
    @ViewBuilder
    private func timeAgo(_ lastActive: Date) -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ZStack {
                    Text(lastActive.formattedOnlineChannel())
                        .font(.footnote)
                        .foregroundStyle(.green)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 7)
                        .background(.black)
                        .clipShape(Capsule())
                    Text(lastActive.formattedOnlineChannel())
                        .font(.footnote)
                        .foregroundStyle(.green)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 4)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())
                }
                .padding(3)
                .padding(.trailing, -8)
            }
        }
    }
}


#Preview {
    ChannelItemView(channel: .placeholder)
}
