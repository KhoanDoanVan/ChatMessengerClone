//
//  DetailCurrentNoteView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 9/10/24.
//

import SwiftUI

struct DetailCurrentNoteView: View {
    
    @Environment(\.dismiss) private var dismiss
    let note: NoteItem
    
    var body: some View {
        VStack(spacing: 20) {
            topNav
            
            mainContent
            
            Button {
                dismiss()
            } label: {
                Text("Leave a new note")
                    .bold()
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(Color(.systemBlue))
            .clipShape(Capsule())
            .padding(.horizontal, 10)
            
            Button("Delete note") {
                dismiss()
            }
            .bold()
        }
        .padding(.bottom, 10)
    }
    
    /// Main content
    private var mainContent: some View {
        VStack {
            ZStack {
                CircularProfileImage(note.owner?.profileImage, size: .xLarge)
                                
                bubbleNote
            }
            .frame(width: 200)
            
            Text("Shared \(note.createAt.formattedOnlineChannel()) ago")
                .foregroundStyle(Color(.systemGray))
        }
        .padding(.top, 30)
    }
    
    /// Bubble Note
    private var bubbleNote: some View {
        VStack(alignment: .leading) {
            noteContentBubble
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
    
    /// Note content
    private var noteContentBubble: some View {
        Text(note.textNote)
            .padding()
            .background(Color(.systemGray5))
            .clipShape(
                .rect(cornerRadius: 20)
            )
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    /// Button Top Trailing
    private var topNav: some View {
        HStack {
            Spacer()
            Button("Done") {
                dismiss()
            }
        }
        .padding(.horizontal, 10)
    }
}

#Preview {
    DetailCurrentNoteView(note: .stubNote)
}
