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
    
    /// Music picker
    @Published var isShowMusicPicker: Bool = false
    @Published var isDetailMusic: Bool = true
    @Published var textSearch: String = ""
    @Published var scrollOffsetXMusic: CGFloat = 0
    @Published var count: Int = 0
    /// Width of the main rectangle
    let mainRectangleWidth: CGFloat = 220
    /// Width of the second rectangle
    let smallRectangleWidth: CGFloat = 30
    var bottomBarContentWidth: CGFloat = 14 * 150 + (190)
    var times: CGFloat {
        return bottomBarContentWidth / 220
    }
    
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
