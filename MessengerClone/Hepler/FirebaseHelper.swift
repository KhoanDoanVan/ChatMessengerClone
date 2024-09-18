//
//  FirebaseHelper.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 21/8/24.
//

import FirebaseStorage
import SwiftUI

struct FirebaseHelper {
    
    typealias UploadCompletion = (Result<URL, Error>) -> Void
    typealias ProgressHandler = (Double) -> Void
    
    // MARK: Upload only Image Photo
    static func uploadImagePhoto(
        _ image: UIImage,
        for type: UploadType,
        completion: @escaping UploadCompletion,
        progressHandler: @escaping ProgressHandler
    ) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        
        /// Path file
        let storagePath = type.filePath
        
        /// Upload to storage
        let uploadTask: StorageUploadTask = storagePath.putData(imageData) { _, error in
            
            /// Upload Error
            if let error = error {
                print("Failed to Upload Image to Storage: \(error.localizedDescription)")
                completion(.failure(UploadError.failedToUploadImage(error.localizedDescription)))
                return
            }
            
            /// Upload Success
            storagePath.downloadURL(completion: completion)
        }
        
        /// Observable upload progress
        uploadTask.observe(.progress) { snapshot in
            guard let progress = snapshot.progress else { return }
            let percentage = Double(progress.completedUnitCount / progress.totalUnitCount) // 98%, 100%
            
            progressHandler(percentage)
        }
    }
    
    // MARK: Upload Video, Audio
    static func uploadFile(for type: UploadType, fileURL: URL, completion: @escaping UploadCompletion, progressHandler: @escaping ProgressHandler) {
        /// Path file
        let storageRef = type.filePath
                
        /// StorageUploadTask is a class provided by Firebase Storage to handle the upload process
        let uploadTask: StorageUploadTask = storageRef.putFile(from: fileURL) { _, error in
            if let error = error {
                print("Failed to Upload File to Storage: \(error.localizedDescription)")
                completion(.failure(UploadError.faliedToUploadFile(error.localizedDescription)))
                return
            }
            
            // completion: (Result<URL, any Error>) -> Void
            storageRef.downloadURL(completion: completion)
        }
        
        /// observable percentage of upload progress (How long will it take to finish the progress??)
        uploadTask.observe(.progress) { snapshot in
            guard let progress = snapshot.progress else { return }
            let percentage = Double(progress.completedUnitCount / progress.totalUnitCount)
            
            /// completion
            progressHandler(percentage)
        }
    }
}

extension FirebaseHelper {
    enum UploadType {
        case profilePhoto
        case photoMessage
        case videoMessage
        case audioMessage
        
        var filePath: StorageReference {
            let filename = UUID().uuidString
            
            switch self {
            case .profilePhoto:
                return FirebaseConstants.StorageRef.child("profile_photo").child(filename)
            case .photoMessage:
                return FirebaseConstants.StorageRef.child("message_photo").child(filename)
            case .videoMessage:
                return FirebaseConstants.StorageRef.child("message_video").child(filename)
            case .audioMessage:
                return FirebaseConstants.StorageRef.child("message_audio").child(filename)
            }
        }
    }
}

enum UploadError: Error {
    case failedToUploadImage(_ description: String)
    case faliedToUploadFile(_ description: String)
}

extension UploadError {
    var errorDescription: String {
        switch self {
        case .failedToUploadImage(let description):
            return description
        case .faliedToUploadFile(let description):
            return description
        }
    }
}
