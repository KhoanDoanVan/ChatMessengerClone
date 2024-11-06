//
//  NewNoteViewModel.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 8/10/24.
//

import Foundation
import FirebaseAuth
import Combine
import FirebaseFirestore
import FirebaseDatabase

class NewNoteViewModel: ObservableObject {
    
    @Published var text: String = ""
    var characterLimit: Int = 60
    
    @Published var currentUser: UserItem?
    @Published var currentNote: NoteItem?
    
    /// Music picker
    @Published var listMusics: [MusicItem] = []
    @Published var musicPicked: MusicItem?
    @Published var isShowMusicPicker: Bool = false
    @Published var isDetailMusic: Bool = false
    @Published var textSearch: String = ""
    @Published var scrollOffsetXMusic: CGFloat = 0
    @Published var count: Int = 0
    /// Width of the main rectangle
    let mainRectangleWidth: CGFloat = 220
    /// Width of the second rectangle
    let smallRectangleWidth: CGFloat = 30
    var bottomBarContentWidth: CGFloat = 14 * 150 + (190)
    var leadingPadding: CGFloat = 14.7714285714
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
    
    /// Fetch list musics
    func fetchListMusics() {
        self.fetchMusicItems { [weak self] musics in
            self?.listMusics = musics
        }
    }
    
    /// Service fetch musics
    private func fetchMusicItems(completion: @escaping ([MusicItem]) -> Void) {
        
        var musics: [MusicItem] = []
        
        FirebaseConstants.MusicsRef.getDocuments { querySnapshot, error in
            if let error {
                print("Error Fetch Musics: \(error)")
                completion([])
            }
            
            for document in querySnapshot!.documents {
                do {
                    let musicItem = try document.data(as: MusicItem.self)
                    musics.append(musicItem)
                } catch {
                    print("Failed to decode MusicItem: \(error)")
                }
            }
            
            completion(musics)
        }
    }
}
