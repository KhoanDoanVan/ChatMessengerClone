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
                        Text(note == nil ? "Post a note" : noteTitle)
                            .font(.system(size: 12))
                            .foregroundStyle(note == nil ? Color(.systemGray) : .white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(Color(.systemGray4))
                            .lineSpacing(-10)
                            .clipShape(Capsule())
                            .multilineTextAlignment(.center)
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
            
            
            
            if isOnline {
                if !isUserCurrent {
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
            } else {
                if !isUserCurrent {
                    HStack {
                        HStack {
                            Spacer()
                            ZStack {
                                Text(note.createAt.formattedOnlineChannel())
                                    .foregroundStyle(.green)
                                    .font(.footnote)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 4)
                                    .background(.black)
                                    .clipShape(Capsule())
                                    .padding(.horizontal, 5)
                                    .padding(.top, 20)
                                Text(note.createAt.formattedOnlineChannel())
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
        }
        .frame(width: 100, height: 100)
        .padding(.top, 30)
        .padding(.bottom, 15)
    }
}

#Preview {
    NoteCellView(isOnline: false, isUserCurrent: false, note: .stubNote, currentUser: .placeholder)
}
