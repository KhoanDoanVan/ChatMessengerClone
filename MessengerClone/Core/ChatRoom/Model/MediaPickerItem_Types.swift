//
//  MediaPickerItem_Types.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 21/8/24.
//

import SwiftUI


struct MediaAttachment: Identifiable, Hashable {
    
    let id: String
    let type: MediaAttachmentType
    var thumbnail: UIImage {
        switch type {
        case .photo(let imageThumbnail):
            return imageThumbnail
        case .video(let imageThumbnail, _, _):
            return imageThumbnail
        case .audio:
            return UIImage()
        case .fileMedia:
            return UIImage()
        }
    }
    var fileUrl: URL? {
        switch type {
        case .photo:
            return nil
        case .video(_, let fileUrl, _):
            return fileUrl
        case .audio(let fileUrl, _):
            return fileUrl
        case .fileMedia(let fileUrl, _):
            return fileUrl
        }
    }
    var durationVideo: TimeInterval? {
        switch type {
        case .photo(_):
            return nil
        case .video( _, _, let duration):
            return duration
        case .audio(_, let duration):
            return duration
        case .fileMedia(_, _):
            return nil
        }
    }
    var sizeOfFile: Int64? {
        switch type {
        case .fileMedia(_, let size):
            return size
        default:
            return nil
        }
    }
}

enum MediaAttachmentType: Hashable {
    case photo(imageThumbnail: UIImage)
    case video(imageThumbnail: UIImage, _ url: URL, _ duration: TimeInterval)
    case audio(_ url: URL, _ duration: TimeInterval)
    case fileMedia(_ url: URL, _ size: Int64)
}
