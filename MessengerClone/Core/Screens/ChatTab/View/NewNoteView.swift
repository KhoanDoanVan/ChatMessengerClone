//
//  NewNoteView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 7/10/24.
//

import SwiftUI

struct NewNoteView: View {
    @FocusState private var isTextFocusState: Bool
    
    @StateObject private var viewModel: NewNoteViewModel
    let handleAction: () -> Void
    
    init(currentNote: NoteItem?, completion: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: NewNoteViewModel(currentNote: currentNote))
        self.handleAction = completion
    }
    
    private var isValidNote: Bool {
        return viewModel.text.isEmpty
    }
    
    var body: some View {
        VStack {
            topView
            Spacer()
            
            mainNote
            Spacer()
            bottomView
        }
        .onAppear {
            isTextFocusState = true
        }
        
    }
    
    /// Main note
    private var mainNote: some View {
        VStack(spacing: 10) {
            ZStack {
                CircularProfileImage(viewModel.currentUser?.profileImage, size: .xLarge)
                                
                bubbleNote
            }
            .frame(width: 200)
            
            Text("\(viewModel.text.count)/\(viewModel.characterLimit)")
                .font(.callout)
                .foregroundStyle(Color(.systemGray2))
            
            Button {
                
            } label: {
                Image(systemName: "music.quarternote.3")
                    .padding()
                    .foregroundStyle(.white)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
                    .bold()
            }
        }
    }
    
    /// Bubble Note
    private var bubbleNote: some View {
        VStack(alignment: .leading) {
            textFieldView
                .shadow(color: Color(.black).opacity(0.45), radius: 1, x: 0, y: 1)
            Circle()
                .frame(width: 20, height: 20)
                .foregroundStyle(Color(.systemGray5))
                .padding(.leading, 25)
                .padding(.top, -20)
            Circle()
                .frame(width: 10, height: 10)
                .foregroundStyle(Color(.systemGray5))
                .padding(.leading, 35)
                .padding(.top, -8)
        }
        .offset(y: -60)
    }
    
    /// Text Field View
    private var textFieldView: some View {
        ZStack {
            Text(viewModel.text)
                .padding()
                .background(Color(.systemGray5))
                .clipShape(
                    .rect(cornerRadius: 20)
                )
                .focused($isTextFocusState)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("", text: $viewModel.text, prompt: Text("Share a thought..."))
                .padding()
                .background(Color(.systemGray5))
                .clipShape(
                    .rect(cornerRadius: 20)
                )
                .focused($isTextFocusState)
                .multilineTextAlignment(.center)
                .opacity(viewModel.text.isEmpty ? 1 : 0)
                .frame(width: 200)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onChange(of: viewModel.text) { oldValue, newValue in
                    /// Limit character of the text
                    viewModel.text = String(viewModel.text.prefix(viewModel.characterLimit))
                }
        }
    }
    
    /// Top Navigation Bar
    private var topView: some View {
        ZStack {
            HStack {
                Button {
                    handleAction()
                } label: {
                    Image(systemName: "xmark")
                }
                Spacer()
                Button("Share") {
                    viewModel.createANote()
                    handleAction()
                }
                .disabled(isValidNote)
            }
            .font(.headline)
            Text("New note")
                .bold()
        }
        .padding(10)
    }
    
    /// Bottom View
    private var bottomView: some View {
        VStack {
            Text("Friends can see your note for 24 hours.")
                .foregroundStyle(Color(.systemGray2))
            Text("Change audience")
                .foregroundStyle(.blue)
        }
        .font(.footnote)
        .bold()
        .padding(.bottom, 10)
    }
}

#Preview {
    NewNoteView(currentNote: .stubNote) {
        
    }
}
