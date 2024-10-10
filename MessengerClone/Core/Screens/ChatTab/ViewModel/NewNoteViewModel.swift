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
    @Published var currentNote: NoteItem?
    private var cancellables = Set<AnyCancellable>()
    
    
    init(currentNote: NoteItem? = nil) {
        self.currentNote = currentNote
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
        if currentNote != nil {
            guard let idNote = currentNote?.id else { return }
            NoteSevice.changeANote(idNote, text) {
                print("Update a Note Success")
            }
        } else {
            NoteSevice.uploadANote(text) {
                print("Create a Note success")
            }
        }
    }
}
