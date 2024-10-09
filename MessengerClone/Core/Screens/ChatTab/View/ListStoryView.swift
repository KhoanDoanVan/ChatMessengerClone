//
//  ListStoryView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 24/7/24.
//

import SwiftUI

struct ListNoteView: View {
    
    @Binding var listNotes: [NoteItem]
    @Binding var currentNote: NoteItem?
    @State private var isOpenCreateNote: Bool = false
    @State private var isOpenDetailNote: Bool = false
    @State private var noteGesture: NoteItem?
    @State private var isOpenSheetNote: Bool = false
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                if currentNote != nil {
                    NoteCellView(isOnline: false, isUserCurrent: true, note: currentNote ?? .stubNote)
                        .onTapGesture {
                            isOpenSheetNote = true
                        }
                } else {
                    NoteCellView(isOnline: false, isUserCurrent: true, note: currentNote ?? .stubNoteCurrent)
                        .onTapGesture {
                            isOpenCreateNote = true
                        }
                }
                ForEach(listNotes) { note in
                    NoteCellView(isOnline: true, isUserCurrent: false, note: note)
                        .onTapGesture {
                            noteGesture = note
                            isOpenDetailNote = true
                        }
                }
            }
        }
        .fullScreenCover(isPresented: $isOpenCreateNote, content: {
            NewNoteView() {
                isOpenCreateNote = false
            }
        })
        .fullScreenCover(isPresented: $isOpenDetailNote, content: {
            if let note = noteGesture{
                DetailNoteView(note: note) {
                    isOpenDetailNote = false
                }
            }
        })
        .sheet(isPresented: $isOpenSheetNote, content: {
            if let currentNote {
                DetailCurrentNoteView(note: currentNote)
                    .presentationDetents([.medium])
            }
        })
        .listRowInsets(EdgeInsets())
    }
}

#Preview {
    ListNoteView(listNotes: .constant([]), currentNote: .constant(.stubNote))
}
