//
//  ChatRoomScreen.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 8/8/24.
//

import SwiftUI
import UniformTypeIdentifiers


struct ChatRoomScreen: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ChatRoomScreenViewModel
    @FocusState private var focusState: Bool
    
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
                VStack(spacing: 0) {
                    Divider()
                    
                    replyView
                    
                    TextInputArea(
                        text: $viewModel.text,
                        isRecording: $viewModel.isRecording,
                        audioLevels: $viewModel.audioLevels,
                        elaspedTime: $viewModel.elaspedTime,
                        isFocus: $focusState
                    ) { action in
                        viewModel.handleTextInputAction(action)
                    }
                    .onChange(of: viewModel.isFocusTextFieldChat) { oldValue, newValue in
                        focusState = newValue // Sync FocusState with ViewModel
                    }
                    .onChange(of: focusState) { oldValue, newValue in
                        viewModel.isFocusTextFieldChat = newValue // Sync ViewModel with FocusState
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
        .fileImporter(
            isPresented: $viewModel.isOpenFileImporter,
            allowedContentTypes: [.item], // Any File Type
            allowsMultipleSelection: false
        ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        viewModel.handleTextInputAction(TextInputArea.UserAction.shareAFile(url))
                    }
                case .failure(let failure):
                    print("Failed to fetch File from fileImporter: \(failure.localizedDescription)!")
                }
            }
        .sheet(isPresented: $viewModel.isOpenPreviewFileText) {
            if let content = viewModel.contentsOfFile,
               let fileName = viewModel.nameOfFile,
               let urlString = viewModel.urlFileDownloaded
            {
                PreviewFileContentView(content: content, fileName: fileName, urlFileDownloaded: urlString) {
                    viewModel.isOpenPreviewFileText = false
                    viewModel.contentsOfFile = nil
                    viewModel.nameOfFile = nil
                    viewModel.urlFileDownloaded = nil
                }
            }
        }
        .confirmationDialog("Who do you want to unsent for?", isPresented: $viewModel.isShowBoxChoiceUnsent) {
            Button("Unsent for everyone", role: .destructive) {
                viewModel.isShowBoxChoiceUnsent = false
            }
            Button("Unsent for you", role: .destructive) {
                viewModel.isShowBoxChoiceUnsent = false
                viewModel.isShowAlertChoiceForYou = true
            }
        }
        .alert(isPresented: $viewModel.isShowAlertChoiceForYou) {
            Alert(
                title: Text("Unsend for you?"),
                message: Text("This will remove the message from your device. Other chat members will still be able to see it."),
                primaryButton: .cancel(),
                secondaryButton: .destructive(Text("Unsend"), action: {
                    viewModel.isShowAlertChoiceForYou = false
                })
            )
        }
    }
    
    /// Reply View
    private var replyView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                if let state = viewModel.messageInteractBlurCurrent?.isNotMe {
                    if state == true {
                        Text("Replying to \(viewModel.messageInteractBlurCurrent?.sender?.username ?? "Unknown")")
                            .foregroundStyle(.white)
                    } else {
                        Text("Replying to yourself")
                            .foregroundStyle(.white)
                    }
                }
                
                switch viewModel.messageInteractBlurCurrent?.type {
                case .text, .replyNote, .replyStory:
                    Text(viewModel.messageInteractBlurCurrent?.text ?? "Unknown")
                        .font(.footnote)
                        .foregroundStyle(Color(.systemGray))
                default:
                    Text(viewModel.messageInteractBlurCurrent?.type.nameOfType ?? "Unknown")
                        .font(.footnote)
                        .foregroundStyle(Color(.systemGray))
                }
            }
            Spacer()
            Button {
                withAnimation {
                    viewModel.isOpenReplyBox = false
                    viewModel.messageInteractBlurCurrent = nil
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.footnote)
                    .bold()
                    .foregroundStyle(.white)
                    .padding(5)
                    .background(Color(.systemGray2))
                    .clipShape(Circle())
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: viewModel.isOpenReplyBox ? 50 : 0)
        .clipped()
        .padding(.horizontal)
        .padding(.vertical, 5)
        .background(Color(.black))
        .animation(.easeInOut, value: viewModel.isOpenReplyBox)
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
