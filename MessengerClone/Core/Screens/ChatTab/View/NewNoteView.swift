//
//  NewNoteView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 7/10/24.
//

import SwiftUI

struct NewNoteView: View {
    @FocusState private var isTextFocusState: Bool
    @State private var text: String = ""
    
    private var isValidNote: Bool {
        return text.isEmpty
    }
    
    var body: some View {
        VStack {
            topView
            Spacer()
            
            mainNote
            Spacer()
            bottomView
        }
        
        
    }
    
    /// Main note
    private var mainNote: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .frame(width: 120, height: 120)
                
                bubbleNote
            }
            .frame(width: 200)
            
            Text("\(text.count)/60")
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
    
    /// Text Field View
    private var textFieldView: some View {
        ZStack {
            Text(text)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(
                    .rect(cornerRadius: 20)
                )
                .focused($isTextFocusState)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("", text: $text, prompt: Text("Share a thought..."))
                .padding()
                .background(Color(.systemGray6))
                .clipShape(
                    .rect(cornerRadius: 20)
                )
                .focused($isTextFocusState)
                .multilineTextAlignment(.center)
                .opacity(text.isEmpty ? 1 : 0)
                .frame(width: 200)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    /// Top Navigation Bar
    private var topView: some View {
        ZStack {
            HStack {
                Button {
                    
                } label: {
                    Image(systemName: "xmark")
                }
                Spacer()
                Button("Share") {
                    
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
    }
}

#Preview {
    NewNoteView()
}
