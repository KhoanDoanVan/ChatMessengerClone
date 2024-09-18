//
//  ExportVideoFile+Helper.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 24/8/24.
//

import Foundation
import AVKit

/// Export the video to a file and return the URL
func exportVideoFile(from avAsset: AVAsset, completion: @escaping (URL?) -> Void) {
    guard let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetHighestQuality) else {
        completion(nil)
        return
    }
    
    let tempDirectory = FileManager.default.temporaryDirectory
    let outputURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mp4")
    
    exportSession.outputURL = outputURL
    exportSession.outputFileType = .mp4
    exportSession.exportAsynchronously {
        switch exportSession.status {
        case .completed:
            completion(outputURL)
        case .failed, .cancelled:
            print("Export failed: \(String(describing: exportSession.error))")
            completion(nil)
        default:
            completion(nil)
        }
    }
}
