//
//  CameraScreenViewModel.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 21/9/24.
//

import Foundation
import AVFoundation
import SwiftUI

@MainActor
class CameraScreenViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var isTaken: Bool = false
    @Published var session: AVCaptureSession = AVCaptureSession()
    @Published var output: AVCapturePhotoOutput = AVCapturePhotoOutput()
    @Published var preview: AVCaptureVideoPreviewLayer!
    @Published var pictureData: Data = Data()
    @Published var uiImage: UIImage?
    
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
    
    /// Take picture
    func takePicture() {
        performBackgroundTask {
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            self.session.stopRunning()
            self.updateUIAfterCapture()
        }
    }
    
    /// Retake picture
    func reTakePicture() {
        performBackgroundTask {
            self.session.startRunning()
            self.updateUIAfterRetake()
        }
    }
    
    /// Save image data
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            self.pictureData = imageData
        } else {
            print("Error processing photo: \(String(describing: error?.localizedDescription))")
        }
    }
    
    // MARK: - Helper Methods
    
    private func performBackgroundTask(_ task: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async { task() }
    }
    
    private func updateUIAfterCapture() {
        DispatchQueue.main.async {
            withAnimation { self.isTaken = true }
        }
    }
    
    private func updateUIAfterRetake() {
        DispatchQueue.main.async {
            withAnimation { self.isTaken = false }
        }
    }
}
