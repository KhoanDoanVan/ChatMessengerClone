//
//  GenerateThumbnailVideo+Helper.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 24/8/24.
//

import Foundation
import SwiftUI
import AVKit

func generateThumbnailVideo(from asset: AVAsset) -> UIImage? {
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    let time = CMTime(seconds: 1.0, preferredTimescale: 600)
    
    do {
        let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
        return UIImage(cgImage: cgImage) // Core Graphics Framework
    } catch {
        print("Failed generateThumbnailVideo: \(error.localizedDescription)")
        return nil
    }
}
