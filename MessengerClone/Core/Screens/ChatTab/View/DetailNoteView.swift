//
//  DetailNoteView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 9/10/24.
//

import SwiftUI

struct DetailNoteView: View {
    @FocusState private var isFocusTextField: Bool
    @StateObject private var viewModel: DetailNoteViewModel
    
    let handleAction: () -> Void
    
    init(note: NoteItem, handleAction: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: DetailNoteViewModel(note: note))
        self.handleAction = handleAction
    }
    
    
    private var isFillText: Bool {
        return !viewModel.text.isEmpty
    }
    
    var body: some View {
        VStack {
            topBar
            Spacer()
            mainContent
            Spacer()
            bottomBar
            
        }
        .onAppear {
            isFocusTextField = true
        }
    }
    
    /// Main content
    private var mainContent: some View {
        VStack {
            ZStack {
                CircularProfileImage(viewModel.note.owner?.profileImage, size: .xLarge)
                                
                bubbleNote
            }
            .frame(width: 200)
            
            Text(viewModel.note.owner?.username ?? "Unknown")
                .bold()
            
            Text("Shared \(viewModel.note.createAt.formattedOnlineChannel()) ago")
                .foregroundStyle(Color(.systemGray))
        }
    }
    
    /// Bubble Note
    private var bubbleNote: some View {
        VStack(alignment: .leading) {
            noteContentBubble
                .shadow(color: Color(.black).opacity(0.45), radius: 1, x: 0, y: 1)
            Circle()
                .frame(width: 20, height: 20)
                .foregroundStyle(Color(.systemGray6))
                .padding(.leading, 25)
                .padding(.top, -20)
            Circle()
                .frame(width: 10, height: 10)
                .foregroundStyle(Color(.systemGray6))
                .padding(.leading, 35)
                .padding(.top, -8)
        }
        .offset(y: -60)
    }
    
    /// Note content
    private var noteContentBubble: some View {
        VStack {
            Text(viewModel.note.textNote)
                .padding(.vertical, viewModel.note.sound != nil ? 0 : 20)
                .padding(.top, viewModel.note.sound != nil ? 20 : 0)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: viewModel.note.sound != nil ? .center : .leading)
            
            if let noteSound = viewModel.note.sound {
                VStack {
                    HStack(spacing: 10){
                        SoundComponent(size: .medium)
                        InfiniteScrollingTextView(text: noteSound.songItem.title, speed: 5, width: 120)
                    }
                    Text(noteSound.songItem.artist)
                        .foregroundStyle(Color(.systemGray))
                }
                .padding(.bottom, 20)
            }
        }
        .padding(.horizontal)
        .background(Color(.systemGray6))
        .clipShape(
            .rect(cornerRadius: 20)
        )
//        Text(viewModel.note.textNote)
//            .padding()
//            .background(Color(.systemGray6))
//            .clipShape(
//                .rect(cornerRadius: 20)
//            )
//            .multilineTextAlignment(.center)
//            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    /// TextField
    private var textField: some View {
        VStack {
            TextField("", text: $viewModel.text, prompt: Text("Send message"))
                .padding(.leading, 10)
                .padding(.trailing, 40)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .clipShape(Capsule())
                .focused($isFocusTextField)
                .overlay(alignment: .trailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "face.smiling")
                            .font(.title2)
                            .padding(10)
                    }
                }
        }
        
    }
    
    /// Bottom Bar
    private var bottomBar: some View {
        VStack {
            if isFillText {
                HStack {
                    textField
                        .frame(maxWidth: .infinity)
                    Button {
                        viewModel.sendReplyNote()
                        isFocusTextField = false
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.title2)
                    }
                }
                .padding(.horizontal, 10)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        textField
                            .frame(width: 250)
                        ForEach(Reaction.allCases, id: \.self) { reaction in
                            Button {
                                
                            } label: {
                                Text(reaction.emoji)
                                    .font(.system(size: 32))
                            }
                        }
                    }
                    .padding(.leading, 10)
                }
            }
        }
        .padding(.bottom, 10)
    }
    
    /// Top Bar
    private var topBar: some View {
        HStack {
            Spacer()
            Button("Done") {
                handleAction()
            }
        }
        .padding(.horizontal, 10)
    }
}

#Preview {
    DetailNoteView(note: .stubNote) {
        
    }
}

