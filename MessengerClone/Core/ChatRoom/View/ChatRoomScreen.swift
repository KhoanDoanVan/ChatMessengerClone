//
//  ChatRoomScreen.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 8/8/24.
//

import SwiftUI

struct ChatRoomScreen: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ChatRoomScreenViewModel
    
    let channel: ChannelItem
    
    init(channel: ChannelItem) {
        self.channel = channel
        self._viewModel = StateObject(wrappedValue: ChatRoomScreenViewModel(channel: channel))
    }
    
    var body: some View {
        VStack {
            // MARK: - Message List View
            MessageListView(viewModel)
            .toolbar(.hidden, for: .tabBar)
            .navigationBarBackButtonHidden()
            .toolbar {
                buttonBack()
                trailingButtons()
                headerChatRoom()
            }
            .safeAreaInset(edge: .bottom) {
                VStack {
                    Divider()
                    TextInputArea(
                        text: $viewModel.text,
                        isRecording: $viewModel.isRecording,
                        audioLevels: $viewModel.audioLevels,
                        elaspedTime: $viewModel.elaspedTime
                    ) { action in
                        viewModel.handleTextInputAction(action)
                    }
                    .padding(.top, 5)
                    .padding(.horizontal, 10)
                }
            }
            
            // MARK: - Picker Photo View
            PickerPhotoView(
                listAttachment: $viewModel.listMediaAttachment,
                listAttachmentPicker: $viewModel.listAttachmentPicker
            ) { action in
                viewModel.handleTextInputAction(action)
            }
            .frame(maxWidth: .infinity)
            .frame(height: viewModel.showPickerAttachment ? 250 : 0)
            .opacity(viewModel.showPickerAttachment ? 1 : 0)
            .animation(.easeInOut, value: viewModel.showPickerAttachment)
            .fullScreenCover(isPresented: $viewModel.isShowVideoCall) {
                if let userCurrent = viewModel.userCurrent {
                    VideoScreen(userCurrent, channel.usersChannel[0], channel) { timeVideoCall in
                        viewModel.isShowVideoCall = false
                        viewModel.sendVideoCallMessage(timeVideoCall)
                    }
                }
            }
            .fullScreenCover(isPresented: $viewModel.isShowCamera) {
                CameraScreen() { action, state in
                    viewModel.handleTextInputAction(action)
                    viewModel.isShowCamera = state
                }
            }
            
            // MARK: - Sticker Picker View
            StickerPickerView(
                listStickers: $viewModel.stickers
            ) { action in
                viewModel.handleTextInputAction(action)
            }
            .frame(maxWidth: .infinity)
            .frame(height: viewModel.isShowSticker ? 250 : 0)
            .opacity(viewModel.isShowSticker ? 1 : 0)
            .animation(.easeInOut, value: viewModel.isShowSticker)
        }
        .sheet(isPresented: $viewModel.displayPreviewVoice) {
            PreviewVoiceRecordView(
                urlRecord: viewModel.urlRecord!,
                levelsPreview: viewModel.previewLevels, 
                playingPreview: $viewModel.playingPreview, 
                elapsedTimePreview: $viewModel.elapsedTimePreview,
                audioDuration: $viewModel.audioDuration
            ) { action in
                viewModel.handleTextInputAction(action)
            }
            .presentationDetents([.height(300)])
        }
        .sheet(isPresented: $viewModel.isShowReactions) {
            if let message = viewModel.messageReactions {
                ReactionShowSheetView(message: message, channel: channel)
                    .presentationDetents([.height(300)])
                    .presentationCornerRadius(20)
            }
        }
        .sheet(isPresented: $viewModel.isShowMapLocation) {
            CurrentLocationSheet() { action in
                viewModel.handleTextInputAction(action)
            }
        }
    }
    
}

extension ChatRoomScreen {
    @ToolbarContentBuilder
    private func buttonBack() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .bold()
            }
        }
    }
    
    @ToolbarContentBuilder
    private func trailingButtons() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 8) {
                Button {
                    viewModel.isShowVideoCall = true
                } label: {
                    Image(systemName: "phone.fill")
                        .bold()
                }
                
                Button {
                    viewModel.isShowVideoCall = true
                } label: {
                    Image(systemName: "video.fill")
                        .bold()
                }
            }
        }
    }
    
    private var channelTitle: String {
        let maxChar = 20
        let trailingChars = channel.title.count > maxChar ? "..." : ""
        let title = String(channel.title.prefix(maxChar) + trailingChars)
        
        return title
    }
    
    @ToolbarContentBuilder
    private func headerChatRoom() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            NavigationLink {
                ConfigChatView()
            } label: {
                HStack {
                    if channel.isGroupChat {
                        CircularProfileImage(channel, size: .xSmall)
                    } else {
                        CircularProfileImage(channel.coverImageUrl,size: .xSmall)
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text(channelTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.messagesBlack)
                        
                        if viewModel.onlinePartnerObject?.state == true {
                            Text("Active now")
                                .font(.footnote)
                                .foregroundStyle(Color(.systemGray))
                        } else {
                            if let time = viewModel.onlinePartnerObject?.lastActive.formattedOnlineState() {
                                Text(time)
                                    .font(.footnote)
                                    .foregroundStyle(Color(.systemGray))

                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatRoomScreen(channel: .placeholder)
    }
}
