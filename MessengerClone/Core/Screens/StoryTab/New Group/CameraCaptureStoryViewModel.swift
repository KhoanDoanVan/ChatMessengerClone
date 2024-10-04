//
//  CameraCaptureStoryViewModel.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 4/10/24.
//

import Foundation
import AVFoundation
import SwiftUI

class CameraCaptureStoryViewModel: ObservableObject {
    
    // MARK: Properties
    @Published var session: AVCaptureSession = AVCaptureSession()
    @Published var output: AVCapturePhotoOutput = AVCapturePhotoOutput()
    
    
    /// Check permission
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUpSession()
        case .notDetermined:
            requestCameraAccess()
        case .denied:
            print("Permission is denied")
        default:
            break
        }
    }
    
    ///
    func requestCameraAccess() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] status in
            if status {
                self?.setUpSession()
            }
        }
    }
    
    /// Set up the camera session
    private func setUpSession() {
        do {
            session.beginConfiguration()
            
            if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) ??
                            AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) { session.addInput(input) }
                if session.canAddOutput(output) { session.addOutput(output) }
            } else {
                print("Error: No camera available")
            }
            
            session.commitConfiguration()
        } catch {
            print("Error setting up camera: \(error.localizedDescription)")
        }
    }
    
}
