//
//  CustomVideoPlayer.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 6/9/24.
//

import SwiftUI
import AVKit
import Foundation

struct CustomVideoPlayerView: UIViewControllerRepresentable {
    
    var player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}

