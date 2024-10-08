//
//  NewNoteViewModel.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 8/10/24.
//

import Foundation
import FirebaseAuth
import Combine

class NewNoteViewModel: ObservableObject {
    
    @Published var text: String = ""
    var characterLimit: Int = 60
    
    @Published var currentUser: UserItem?
    private var cancellables = Set<AnyCancellable>()
    
    
    init() {
        AuthManager.shared.authState
            .sink { [weak self] authState in
                switch authState {
                case .loggedIn(let user):
                    self?.currentUser = user
                default:
                    self?.currentUser = nil
                }
            }
            .store(in: &cancellables)
    }
    
    /// Create A Note
    func createANote() {
        NoteSevice.uploadANote(text) {
            print("Upload Note success")
        }
    }
}
