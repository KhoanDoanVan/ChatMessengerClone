//
//  BlurViewModel.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 5/9/24.
//

import Foundation
import UIKit
import SwiftUI

class BlurViewModel: ObservableObject {
    
    @Published var blurView: UIVisualEffectView?
    
    // MARK: Animation Frame
    @Published var startingFrame: CGRect?
    @Published var focusedView: UIView?
    @Published var highlightCell: UICollectionViewCell?
    
    func blurViewAction(_ action: MessageListController.BlurMessageViewAction) {
        switch action {
        case .closeBlurViewImage:
            dismissPreviewImage()
        case .closeBlurViewVideo:
            dismissPreviewVideo()
        }
    }
    
    /// Action click mark
    private func dismissBlurView() {
        blurView?.removeFromSuperview()
    }
    
    /// Dismiss Preview Image
    @objc private func dismissPreviewImage() {
       UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseOut) { [weak self] in
            guard let self else { return }
            focusedView?.transform = .identity
            focusedView?.frame = startingFrame ?? .zero
            blurView?.alpha = 0
        } completion: { [weak self] _ in
            guard let self else { return }
            highlightCell?.alpha = 1
            focusedView?.removeFromSuperview()
            blurView?.removeFromSuperview()
            focusedView = nil
            blurView = nil
        }
    }
    
    /// Dismiss Preview Video
    @objc private func dismissPreviewVideo() {
        focusedView?.alpha = 1
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseOut) { [weak self] in
             guard let self else { return }
             focusedView?.transform = .identity
             focusedView?.frame = startingFrame ?? .zero
             blurView?.alpha = 0
         } completion: { [weak self] _ in
             guard let self else { return }
             highlightCell?.alpha = 1
             focusedView?.removeFromSuperview()
             blurView?.removeFromSuperview()
             focusedView = nil
             blurView = nil
         }
    }
}
