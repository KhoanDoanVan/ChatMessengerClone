//
//  ChatRoomScreenViewModel.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 18/8/24.
//
import Foundation
import Combine
import Firebase
import Photos
import SwiftUI

enum MessageReactionPicker {
    case picker(_ message: MessageItem)
}

@MainActor
class ChatRoomScreenViewModel: ObservableObject {
    
    // MARK: Propertises
    private(set) var channel: ChannelItem
    var userCurrent: UserItem?
    
    // MARK: Fetch Messages Propertises
    @Published var messages = [MessageItem]()
    private var subscription = Set<AnyCancellable>()
    
    // MARK: Pagination Messages
    @Published var paginating: Bool = false
    private var firstMessage: MessageItem?
    private var currentPage: String?
    var isPaginable: Bool {
        return currentPage != firstMessage?.id
    }
    
    // MARK: Action Propertises
    @Published var text: String = ""
    @Published var showPickerAttachment: Bool = false
    
    // MARK: List Image,Video from Photos
    @Published var listAttachmentPicker = [MediaAttachment]()
    @Published var listMediaAttachment = [MediaAttachment]()
    
    // MARK: Scroll To Bottom Action
    @Published var scrollToBottom: (scroll: Bool, isAnimate: Bool) = (false, false)
    
    // MARK: Recording
    @Published var audioLevels: [CGFloat] = []
    @Published var audioFloatForDB: [Float] = []
    @Published var previewLevels: [CGFloat] = []
    @Published var isRecording: Bool = false
    @Published var audioRecorder: AVAudioRecorder?
    @Published var displayPreviewVoice: Bool = false
    @Published var urlRecord: URL?
    @Published var startTime: Date?
    @Published var elaspedTime: TimeInterval = 0
    @Published var elapsedTimePreview: TimeInterval = 0
    @Published var timer: AnyCancellable?
    @Published var audioDuration: TimeInterval = 0
    @Published var playingPreview: Bool = false
    
    // MARK: Reaction
    @Published var isShowReactions: Bool = false
    
    // MARK: Listen Message Reactions Picker
    @Published var messageReactions: MessageItem?
    
    // MARK: VideoCall
    @Published var isShowVideoCall: Bool = false
    
    // MARK: Sticker
    @Published var stickers: [DataClass] = []
    @Published var isShowSticker: Bool = false
    
    var avAudioPlayer: AVAudioPlayer?
    
    // MARK: Init
    init(channel: ChannelItem) {
        self.channel = channel
        listenToAuthState()
    }
    
    /// Listen messages
    private func listenToAuthState() {
        AuthManager.shared.authState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                switch state {
                case .loggedIn(let userCurrent):
                    self.userCurrent = userCurrent
                    self.fetchHistoryMessages()
                default:
                    break
                }
            }
            .store(in: &subscription)
    }
    
    /// Get All Messages
    private func fetchAllMessages() {
        MessageService.getMessages(for: channel) { messages in
            self.messages = messages
            self.scrollToBottomAction(isAnimated: false)
        }
    }
    
    /// Fetch History Messages
    func fetchHistoryMessages() {
        paginating = currentPage != nil
        MessageService.getHistoryMessages(for: channel, lastCursor: currentPage, pageSize: 12) { [weak self] messageNode in
            if self?.currentPage == nil {
                self?.fetchFirstMessage()
                self?.listenNewMessage()
            }
            self?.messages.insert(contentsOf: messageNode.messages, at: 0)
            if self?.currentPage == nil {
                self?.messages.removeLast()
            }
            self?.currentPage = messageNode.currentCursor
            self?.scrollToBottomAction(isAnimated: false)
            self?.paginating = false
        }
    }
    
    /// Pagination more message
    func paginationMoreMessage() {
        guard isPaginable else {
            paginating = false
            return
        }
        fetchHistoryMessages()
    }
    
    /// Fetch First Messages
    private func fetchFirstMessage() {
        MessageService.getFirstMessage(channel) { [weak self] message in
            self?.firstMessage = message
        }
    }
    
    /// Listen for new message
    private func listenNewMessage() {
        MessageService.listenToMessage(channel) { [weak self] newMessage in
            self?.messages.append(newMessage)
            self?.scrollToBottomAction(isAnimated: false)
        } onUpdateMessages: { updateMessage in
            if let index = self.messages.firstIndex(where: { $0.id == updateMessage.id }) {
                self.messages[index] = updateMessage
            }
        }

    }
    
    /// Handle Text Input Area
    func handleTextInputAction(_ action: TextInputArea.UserAction) {
        switch action {
        case .sendTextMessage:
            sendTextMessage(text)
        case .presentPhotoPicker:
            showPhotoPicker()
        case .sendImagesMessage:
            sendMediasMessage(listAttachmentPicker)
        case .pickerAttachment(let attachment):
            actionPickerAttachment(attachment)
        case .startRecording:
            startRecording()
        case .stopRecording:
            stopRecording()
        case .deleteRecording:
            deleteRecord()
        case .deletePreviewRecording:
            deleteRecord()
        case .reRecord:
            deleteRecord()
            startRecording()
        case .actionPreviewRecord:
            actionPreviewRecord()
        case .sendRecord:
            sendAudioMessage(text: text)
        case .presentStickers:
            showStickerPicker()
        case .pickerSticker(let sticker):
            sendStickerMessage(sticker.images.fixedHeight.url)
        }
    }
    
    /// Fetch Stickers
    func fetchStickers(completion: @escaping ([DataClass]?) -> Void) {
        guard let url = URL(string: "https://api.mojilala.com/v1/stickers/trending?api_key=dc6zaTOxFJmzC") else {
            print("URL Not Exactly")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to fetch data: \(String(describing: error?.localizedDescription))")
                completion(nil)
                return
            }
            
            do {
                let stickerResponse = try JSONDecoder().decode(Welcome.self, from: data)
                completion(stickerResponse.data) // No optional chaining needed here
            } catch {
                print("Failed to decode JSON: \(error)")
                completion(nil)
            }
        }.resume()
    }
        
    /// Send message action
    private func sendTextMessage(_ text: String) {
        guard let userCurrent = userCurrent else { return }
        MessageService.sendTextMessage(to: channel, from: userCurrent, text) { [weak self] in
            self?.text = ""
        }
    }
    
    /// Send duration of video call message
    func sendVideoCallMessage(_ timeVideoCall: TimeInterval) {
        guard let userCurrent = userCurrent else { return }
        
        if timeVideoCall != 0 {
            MessageService.sendVideoCallMessage(to: channel, from: userCurrent, timeVideoCall) {
                print("sendVideoCallMessage success")
            }
        }
    }
    
    /// Send images message action
    private func sendMediasMessage(_ listAttachmentPicker: [MediaAttachment]) {
        sendMultipleMediaMessage(text, attachments: listAttachmentPicker)
        self.listAttachmentPicker = []
        self.showPickerAttachment = false
    }
    
    /// Send sticker message action
    private func sendStickerMessage(_ urlSticker: String) {
        guard let userCurrent = userCurrent else { return }
        
        MessageService.sendStickerMessage(to: channel, from: userCurrent, urlSticker) {
            print("send Sticker success")
        }
    }
    
    /// Show photoPicker
    private func showPhotoPicker() {
        self.showPickerAttachment.toggle()
        self.listAttachmentPicker = []
        if listMediaAttachment.isEmpty {
            permission()
        }
    }
    
    /// Show sticker Picker
    private func showStickerPicker() {
        self.isShowSticker.toggle()
        /// Fetch Stickers
        if stickers.isEmpty {
            fetchStickers() { stickers in
                if let stickers = stickers {
                    self.stickers = stickers
                    print("Fetch stickers success")
                } else {
                    print("Failed to load stickers")
                }
            }
        }
    }
    
    /// Show sender name
    func showSenderName(for message: MessageItem, at index: Int) -> Bool {
        guard channel.isGroupChat else { return false }
        
        let priorIndex = max(0, index - 1)
        let messagePrior = messages[priorIndex]
        
        return !message.containSameOwner(as: messagePrior)
    }
    
    /// Show sender avatar
    func showSenderAvatar(for message: MessageItem, at index: Int) -> Bool {
        /// Ensure we don't go out of bounds
        let nextIndex = index + 1
        guard nextIndex < messages.count else { return true } // Show avatar for the last message

        let messageNext = messages[nextIndex]
        let isNewDay = isNewDayNext(for: message, at: index)
        
        if isNewDay {
            return true
        } else {
            return !message.containSameOwner(as: messageNext)
        }
    }

    /// Check permissions Photos
    private func permission() {
        let status = PHPhotoLibrary.authorizationStatus()
        
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { [weak self] newStatus in
                if newStatus == .authorized {
                    self?.fetchImagesFromPhotos()
                }
            }
        } else if status == .authorized {
            fetchImagesFromPhotos()
        }
    }
    
    /// Fetch Images
    private func fetchImagesFromPhotos() {
        
        /// fetch the images from photo library
        let fetchOptions = PHFetchOptions()
        /// sort by creation date
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        /// get 30 images
        fetchOptions.fetchLimit = 30
        /// get images
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        let imageManager = PHCachingImageManager()
        
        fetchResult.enumerateObjects { [weak self] asset, _, _ in
            let targetSize = CGSize(width: 100 * UIScreen.main.scale, height: 100 * UIScreen.main.scale)
            let options = PHImageRequestOptions()
            options.isSynchronous = false
            options.deliveryMode = .highQualityFormat
            
            switch asset.mediaType {
            case .image:
                /// request image
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { [weak self ] uiImage, _ in
                    if let uiImage = uiImage {
                        let attachmentImage = MediaAttachment(id: UUID().uuidString, type: .photo(imageThumbnail: uiImage))
                        DispatchQueue.main.async {
                            self?.listMediaAttachment.append(attachmentImage)
                        }
                    }
                }
            case .video:
                /// request video
                let videoOptions = PHVideoRequestOptions()
                videoOptions.deliveryMode = .highQualityFormat
                
                imageManager.requestAVAsset(forVideo: asset, options: videoOptions) { [weak self] avAsset, _, _ in
                    if let avAsset = avAsset {
                        /// Generate video thumbnail
                        guard let videoThumbnail = generateThumbnailVideo(from: avAsset) else { return }
                        
                        Task { [weak self] in
                            guard let self = self else { return }
                            do {
                                /// Get duration of the video
                                let cmTime = try await avAsset.load(.duration)
                                let durationVideo = TimeInterval(CMTimeGetSeconds(cmTime))
                                
                                /// Export Video and get URL
                                exportVideoFile(from: avAsset, completion: { videoUrl in
                                    if let videoUrl = videoUrl {
                                        let attachmentVideo = MediaAttachment(id: UUID().uuidString, type: .video(imageThumbnail: videoThumbnail, videoUrl, durationVideo))
                                        DispatchQueue.main.async {
                                            self.listMediaAttachment.append(attachmentVideo)
                                        }
                                    }
                                })
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            default:
                break
            }
        }
    }
    
    /// Action Picker Image
    func actionPickerAttachment(_ attachment: MediaAttachment) {
        if let attachment = listAttachmentPicker.first(where: { $0.id == attachment.id }) {
            let index = listAttachmentPicker.firstIndex(where: { $0.id == attachment.id })
            listAttachmentPicker.remove(at: index!)
        } else {
            listAttachmentPicker.append(attachment)
        }
    }
    
    /// Upload Image Message to Storage
    private func uploadImageToStorage(_ attachment: MediaAttachment, completion: @escaping(_ imageUrl: URL) -> Void ){
        FirebaseHelper.uploadImagePhoto(attachment.thumbnail, for: .photoMessage) { result in
            switch result {
                
            case .success(let imageUrl):
                completion(imageUrl)
            case .failure(let failure):
                print("Failure uploadImageToStorage with error: \(failure.localizedDescription)")
            }
        } progressHandler: { progress in
            print("Progress uploadImageToStorage: \(progress)")
        }
    }
    
    /// Upload File (Audio,Video) to Storage
    private func uploadFileToStorage(_ attachment: MediaAttachment, for uploadType: FirebaseHelper.UploadType, completion: @escaping(_ fileUrl: URL) -> Void) {
        guard let fileURLToUpload = attachment.fileUrl else { return }

        FirebaseHelper.uploadFile(for: uploadType, fileURL: fileURLToUpload) { result in
            switch result {
                
            case .success(let fileURL):
                completion(fileURL)
            case .failure(let error):
                print("Failed to upload file to Storage: \(error.localizedDescription)")
            }
        } progressHandler: { progress in
            print("UPLOAD FILE PROGRESS: \(progress)")
        }

    }
    
    /// Send photo message
    private func sendPhotoMessage(text: String, _ attachment: MediaAttachment) {
        uploadImageToStorage(attachment) { [weak self] imageUrl in
            guard let self,
                  let userCurrent
            else { return }
            
            let uploadParams: MessageMediaUploadParams = MessageMediaUploadParams(
                channel: channel,
                text: text,
                type: .photo,
                attachment: attachment,
                sender: userCurrent,
                thumbnailUrl: imageUrl.absoluteString
            )
            
            MessageService.sendMediaMessage(to: channel, params: uploadParams) {
                print("sendPhotoMessage success with imageUrl: \(imageUrl)")
                self.scrollToBottomAction(isAnimated: true)
            }
        }
    }
    
    /// Send video message
    private func sendVideoMessage(text: String, _ attachment: MediaAttachment) {
        uploadFileToStorage(attachment, for: .videoMessage) { [weak self] videoURL  in
            // Upload the video thumbnail
            self?.uploadImageToStorage(attachment, completion: { [weak self] imageUrl in
                guard let self = self,
                      let userCurrent,
                      let duration = attachment.durationVideo
                else { return }
                                
                let uploadParams = MessageMediaUploadParams(
                    channel: channel,
                    text: text,
                    type: .video,
                    attachment: attachment,
                    sender: userCurrent,
                    thumbnailUrl: imageUrl.absoluteString,
                    videoURL: videoURL.absoluteString,
                    videoDuration: duration
                )
                
                MessageService.sendMediaMessage(to: self.channel, params: uploadParams) {
                    self.scrollToBottomAction(isAnimated: true)
                }
            })
        }
    }
    
    /// Send audio message
    private func sendAudioMessage(text: String) {
        guard let urlRecord,
              let userCurrent
        else { return }
        
        /// set attachment
        let attachment = MediaAttachment(id: UUID().uuidString, type: .audio(urlRecord, audioDuration))
        
        uploadFileToStorage(attachment, for: .audioMessage) { [weak self] audioURL in
            
            guard let self else { return }
            
            let uploadParams = MessageMediaUploadParams(
                channel: channel,
                text: text,
                type: .audio,
                attachment: attachment,
                sender: userCurrent,
                audioURL: audioURL.absoluteString,
                audioDuration: audioDuration,
                audioLevels: audioFloatForDB
            )
            
            MessageService.sendMediaMessage(to: self.channel, params: uploadParams) { [weak self] in
                self?.scrollToBottomAction(isAnimated: true)
            }
        }
    }
    
    /// Send multiple media
    private func sendMultipleMediaMessage(_ text: String, attachments: [MediaAttachment]) {
        
        for (_, attachment) in attachments.enumerated() {
            
            switch attachment.type {
            case .photo:
                sendPhotoMessage(text: text, attachment)
            case .video:
                sendVideoMessage(text: text, attachment)
            case .audio:
                sendAudioMessage(text: text)
            }
        }
    }
    
    /// Scroll To Bottom
    private func scrollToBottomAction(isAnimated: Bool) {
        scrollToBottom.scroll = true
        scrollToBottom.isAnimate = isAnimated
    }
    
    /// Start recording
    private func startRecording() {
        isRecording = true
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let settings: [String:Any] = [
                AVFormatIDKey: Int(kAudioFormatAppleLossless),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            /// url
            let url = FileManager.default.temporaryDirectory.appending(path: "tempRecording.m4a", directoryHint: .isDirectory)
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            /// Save url
            urlRecord = url
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            /// save start time
            startTime = Date()
            startTimer()
            
            Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) {[weak self] timer in
                guard let recorder = self?.audioRecorder,
                      recorder.isRecording
                else {
                    timer.invalidate()
                    return
                }
                
                recorder.updateMeters()
                let level = recorder.averagePower(forChannel: 0)
                /// The array save float for upload to database
                self?.audioFloatForDB.append(level)
                
                let normalizedLevel = self?.normalizedAudioLevel(level:level)
                /// preview
                let normalizedLevelPreview = self?.normalizedAudioLevelPreview(level: level)
                
                /// Add Preview Levels
                self?.previewLevels.append(normalizedLevelPreview ?? 0)
                
                /// animate record with levels
                if self?.audioLevels.count ?? 0 > 35 {
                    self?.audioLevels.removeFirst()
                }
                self?.audioLevels.append(normalizedLevel ?? 0)
            }
            
        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    /// Stop recording
    private func stopRecording() {
        audioDuration = elaspedTime
        displayPreviewVoice = true
        /// reset
        resetRecording()
    }
    
    /// Delete record
    private func deleteRecord() {
        resetRecording()
        previewLevels.removeAll()
    }
    
    /// Reset property record
    func resetRecording() {
        audioRecorder?.stop()
        elaspedTime = 0
        audioLevels.removeAll()
        audioRecorder = nil
        isRecording = false
        timer?.cancel()
    }
    
    /// Start Timer
    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let startTime = self?.startTime else { return }
                self?.elaspedTime = Date().timeIntervalSince(startTime)
            }
    }
    
    /// Normalize the audio level to a suitable height for the UI
    func normalizedAudioLevel(level: Float) -> CGFloat {
        let level = max(0.2, CGFloat(level + 35) / 2.5)
        return CGFloat(level * 2)
    }

    /// Normalize the audio level preview to a suitable height for the UI
    func normalizedAudioLevelPreview(level: Float) -> CGFloat {
        let level = max(0.2, CGFloat(level + 45) / 2.5)
        return CGFloat(level * 2)
    }
    
    /// Action preview audio voice (play, pause, stop)
    func actionPreviewRecord() {
        if playingPreview {
            playSoundAudio(urlRecord)
        } else {
            pauseSoundAudio()
        }
    }
    
    /// Play sound audio
    private func playSoundAudio(_ url: URL?) {
        if elapsedTimePreview != 0 {
            avAudioPlayer?.play()
        } else {
            guard let url = url else { return }
            
            do {
                avAudioPlayer = try AVAudioPlayer(contentsOf: url)
                avAudioPlayer?.play()
            } catch {
                print("Couldn't play av audio player!")
            }
        }
    }
    
    /// Pause sound audio
    private func pauseSoundAudio() {
        avAudioPlayer?.pause()
    }
    
    /// Check The Message is new day or not
    func isNewDay(for message: MessageItem, at index: Int) -> Bool {
        let priorIndex = max(0, index - 1)
        let priorMessage = messages[priorIndex]
        return !message.timeStamp.isSameDay(as: priorMessage.timeStamp)
    }
    
    /// Check The Message is new day or not
    func isNewDayNext(for message: MessageItem, at index: Int) -> Bool {
        let nextIndex = index + 1
        
        guard nextIndex < messages.count else { return true }
        let priorIndex = max(0, nextIndex)
        let priorMessage = messages[priorIndex]
        return !message.timeStamp.isSameDay(as: priorMessage.timeStamp)
    }
}
