//
//  AddToStoryViewModel.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 24/9/24.
//

import Foundation
import PhotosUI

class AddToStoryViewModel: ObservableObject {
    
    @Published var isShowStoryBoard: Bool = false
    
    @Published var listMediaAttachment = [MediaAttachment]()
    @Published var uiImagePicker: UIImage?
    
    init() {
        fetchMediaFromPhotos()
    }
    
    private func fetchMediaFromPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        fetchOptions.fetchLimit = 30
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        let imageManager = PHCachingImageManager()
        
        fetchResult.enumerateObjects { [weak self] asset , _, _ in
            let targetSize = CGSize(width: 100 * UIScreen.main.scale, height: 100 * UIScreen.main.scale)
            let options = PHImageRequestOptions()
            options.isSynchronous = false
            options.deliveryMode = .highQualityFormat
            
            switch asset.mediaType {
            case .image:
                /// request image
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { [weak self] uiImage, _ in
                    if let uiImage = uiImage {
                        let attachmentImage = MediaAttachment(id: UUID().uuidString, type: .photo(imageThumbnail: uiImage))
                        DispatchQueue.main.async {
                            self?.listMediaAttachment.append(attachmentImage)
                        }
                    }
                }
            default:
                break
            }
        }
    }
}
