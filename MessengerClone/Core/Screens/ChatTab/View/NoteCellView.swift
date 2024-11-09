//
//  NoteCellView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 7/10/24.
//

import SwiftUI

struct NoteCellView: View {
    
    let isOnline: Bool
    let isUserCurrent: Bool
    let note: NoteItem
    let currentUser: UserItem?
    
    
    
    private var noteTitle: String {
        let maxChar = 25
        let trailingChars = note.textNote.count > maxChar ? "..." : ""
        let title = String(note.textNote.prefix(maxChar) + trailingChars)
        
        return title
    }
    
    private var noteArtistString: String {
        let maxChar = 10
        if let noteSong = note.sound {
            let trailingChars = noteSong.songItem.artist.count > maxChar ? "..." : ""
            let title = String(noteSong.songItem.artist.prefix(maxChar) + trailingChars)
            return title
        } else {
            return "unknown"
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 3) {
                if currentUser != nil {
                    CircularProfileImage(currentUser?.profileImage, size: .large)
                } else {
                    CircularProfileImage(note.owner?.profileImage, size: .large)
                }
                
                Text((isUserCurrent ? "Your Note" : note.owner?.username) ?? "")
                    .font(.footnote)
                    .foregroundStyle(note == nil ? Color(.systemGray3) : .white)
            }
            
            VStack(alignment: .leading) {
                ZStack {
                    VStack(spacing: 0) {
                        bubble
                        Circle()
                            .frame(width: 15, height: 15)
                            .foregroundStyle(Color(.systemGray4))
                            .padding(.trailing, 50)
                            .padding(.top, -8)
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundStyle(Color(.systemGray4))
                            .padding(.trailing, 40)
                            .padding(.top, 0)
                    }
                    .padding(.top, -15)
                }
                Spacer()
            }
            
            if (note.isOwnerOnline?.0 ?? false) {
                onlineIcon
            } else if (note.isOwnerOnline?.0 ?? false) && (note.isOwnerOnline?.1?.formattedOnlineChannel() == "second") {
                onlineIcon
            } else if (!(note.isOwnerOnline?.0 ?? false)) && (note.isOwnerOnline?.1?.formattedOnlineChannel() == "") {
                
            } else if (!(note.isOwnerOnline?.0 ?? false)) {
                if let lastActive = note.isOwnerOnline?.1 {
                    timeAgo(lastActive)
                }
            }
        }
        .frame(width: 120, height: 120)
        .padding(.top, 30)
        .padding(.bottom, 15)
    }
    
    /// Bubble
    private var bubble: some View {
        VStack(spacing: 0) {
            Text(note == nil ? "Post a note" : noteTitle)
                .font(.system(size: 12))
                .foregroundStyle(note == nil ? Color(.systemGray) : .white)
                .padding(.horizontal, 12)
                .padding(.vertical, note.sound != nil ? 5 : 0)
                .padding(.vertical, note.sound != nil ? 0 : 5)
                .background(Color(.systemGray4))
                .lineSpacing(-10)
                .clipShape(
                    .rect(cornerRadius: 15)
                )
                .multilineTextAlignment(.center)
            
            if let noteSound = note.sound {
                VStack(spacing: 5) {
                    HStack(spacing: 5) {
                        SoundComponent(size: .mini)
                        InfiniteScrollingTextView(text: noteSound.songItem.title, speed: 5, width: 50)
                    }
                    Text(noteArtistString)
                        .font(.system(size: 11))
                        .foregroundStyle(Color(.systemGray))
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 5)
            }
        }
        .background(Color(.systemGray4))
        .clipShape(
            .rect(cornerRadius: 15)
        )
        .shadow(color: Color(.black).opacity(0.45), radius: 1, x: 0, y: 1)
    }
    
    
    /// Is Online Icon
    private var onlineIcon: some View {
        HStack {
            Spacer()
            ZStack {
                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.messagesWhite)
                Circle()
                    .frame(width: 15, height: 15)
                    .foregroundStyle(.green)
            }
            .padding(.top, 25)
            .padding(.horizontal, 8)
        }
    }
    
    /// Time Ago
    private func timeAgo(_ lastActive: Date) -> some View {
        HStack {
            HStack {
                Spacer()
                ZStack {
                    Text(lastActive.formattedOnlineChannel())
                        .foregroundStyle(.green)
                        .font(.footnote)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 4)
                        .background(.black)
                        .clipShape(Capsule())
                        .padding(.horizontal, 5)
                        .padding(.top, 20)
                    Text(lastActive.formattedOnlineChannel())
                        .foregroundStyle(.green)
                        .font(.footnote)
                        .padding(.horizontal, 2)
                        .padding(.vertical, 1)
                        .background(Color(.systemGray4))
                        .clipShape(Capsule())
                        .padding(.horizontal, 5)
                        .padding(.top, 20)
                }
            }
        }
    }
}

#Preview {
    NoteCellView(isOnline: false, isUserCurrent: false, note: .stubNote, currentUser: .placeholder)
}
