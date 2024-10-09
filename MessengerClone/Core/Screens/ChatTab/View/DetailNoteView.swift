//
//  DetailNoteView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 9/10/24.
//

import SwiftUI

struct DetailNoteView: View {
    
    let note: NoteItem
    @State private var text: String = ""
    @FocusState private var isFocusTextField: Bool
    
    private var isFillText: Bool {
        return !text.isEmpty
    }
    
    let handleAction: () -> Void
    
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
                CircularProfileImage(note.owner?.profileImage, size: .xLarge)
                                
                bubbleNote
            }
            .frame(width: 200)
            
            Text(note.owner?.username ?? "Unknown")
                .bold()
            
            Text("Shared \(note.createAt.formattedOnlineChannel()) ago")
                .foregroundStyle(Color(.systemGray))
        }
    }
    
    /// Bubble Note
    private var bubbleNote: some View {
        VStack(alignment: .leading) {
            noteContentBubble
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
        Text(note.textNote)
            .padding()
            .background(Color(.systemGray6))
            .clipShape(
                .rect(cornerRadius: 20)
            )
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    /// TextField
    private var textField: some View {
        TextField("", text: $text, prompt: Text("Send message"))
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
    
    /// Bottom Bar
    private var bottomBar: some View {
        VStack {
            if isFillText {
                HStack {
                    textField
                        .frame(maxWidth: .infinity)
                    Button {
                        withAnimation {
                            text = ""
                        }
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

