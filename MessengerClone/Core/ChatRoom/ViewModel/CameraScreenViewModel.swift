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
    
    /// Convert Data to UIImage
    func transformDataToUIImage(completion: @escaping(UIImage?) -> Void) {
        if pictureData.isEmpty {
            print("Picture data is empty. Cannot convert to UIImage.")
            completion(nil)
            return
        }

        guard let uiImage = UIImage(data: pictureData) else {
            print("Failed to convert data to UIImage")
            completion(nil)
            return
        }
        
        self.uiImage = uiImage
        
        completion(uiImage)
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
            /// Setting configs...
            self.session.beginConfiguration()
            
            /// Change for your own...
            guard let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) ??
                                AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                print("Error: No camera available")
                return
            }
            
            let input = try AVCaptureDeviceInput(device: device)
            
            /// Checking and adding to session...
            if self.session.canAddInput(input) {
                self.session.addInput(input)
            }
            
            /// Same for output...
            if self.session.canAddOutput(self.output) {
                self.session.addOutput(self.output)
            }
            
            self.session.commitConfiguration()
        } catch {
            print(error.localizedDescription)
        }
    }
    /// Take picture
    func takePicture() {
        DispatchQueue.global(qos: .background).async {
            
            /// Need inherit AVCapturePhotoCaptureDelegate for set delegate
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            self.session.stopRunning()
            
            DispatchQueue.main.async {
                withAnimation {
                    self.isTaken = true
                }
            }
        }
    }
    
    /// Retake picture
    func reTakePicture() {
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
            
            DispatchQueue.main.async {
                withAnimation{
                    self.isTaken = false
                }
            }
        }
    }
    
    /// Save image data
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil {
            print("Error PhotoOutput: \(error?.localizedDescription)")
            return
        }
        print("PhotoOutput running")
        if let imageData = photo.fileDataRepresentation() {
            self.pictureData = imageData
            print("pictureData: \(pictureData)")
        } else {
            print("Error processing photo: \(String(describing: error?.localizedDescription))")
        }
    }
}
