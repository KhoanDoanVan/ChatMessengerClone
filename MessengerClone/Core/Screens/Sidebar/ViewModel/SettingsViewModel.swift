//
//  SettingsViewModel.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 21/8/24.
//

import Foundation
import _PhotosUI_SwiftUI
import Combine
import FirebaseAuth

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var profilePhoto: MediaAttachment?
    private var user: UserItem
    
    private var subscription: AnyCancellable?
    
    init(_ user: UserItem) {
        self.user = user
        self.onPhotoPickerSelection()
    }
    
    /// Setup subscription for listen change of PhotoPickerItem
    private func onPhotoPickerSelection() {
        subscription = $selectedPhotoItem
            .receive(on: DispatchQueue.main)
            .sink { [weak self] photoItem in
                guard let photoItem else { return }
                self?.parsePhotoItemToUIImage(photoItem)
            }
    }
    
    /// Parse photo item data to UIImage
    private func parsePhotoItemToUIImage(_ photoItem: PhotosPickerItem) {
        Task {
            guard let data = try? await photoItem.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data)
            else { return }
            
            self.profilePhoto = MediaAttachment(id: UUID().uuidString, type: .photo(imageThumbnail: uiImage))
        }
    }
    
    /// Upload Profile Image Storage
    func uploadProfileImage() {
        guard let profilePhotoThumbnail = profilePhoto?.thumbnail else { return }
        
        FirebaseHelper.uploadImagePhoto(profilePhotoThumbnail, for: .profilePhoto) { result in
            switch result {
                
            case .success(let imageUrl):
                self.updateUserProfileImageData(imageUrl)
            case .failure(let failure):
                print("Failure Upload Image with error: \(failure.localizedDescription)")
            }
        } progressHandler: { percentage in
            print("Upload profile image with progress: \(percentage)")
        }
    }
    
    /// Change Value ProfileImageUrl of User Data
    private func updateUserProfileImageData(_ imageURL: URL) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        /// Update profile image
        FirebaseConstants.UserRef.child(currentUid).child(.profileImage).setValue(imageURL.absoluteString)
        
        user.profileImage = imageURL.absoluteString
        /// Set state auth
        AuthManager.shared.authState.send(.loggedIn(user))
    }
}
