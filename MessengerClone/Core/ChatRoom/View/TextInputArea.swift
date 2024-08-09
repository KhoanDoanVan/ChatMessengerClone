//
//  TextInputArea.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 9/8/24.
//

import SwiftUI

struct TextInputArea: View {
    @State private var text: String = ""
    @State private var minimumAction: Bool = false
    
    var body: some View {
        HStack(spacing: 15) {
            if !minimumAction {
                buttonMore()
                buttonCamera()
                buttonPhoto()
                buttonVoice()
            } else {
                Button {
                    minimumAction = false
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                }
            }
            
            textFieldSmall()
            
            buttonEmoji()
        }
        .padding(.horizontal, 5)
        .animation(.bouncy, value: minimumAction)
    }
    
    private func buttonEmoji() -> some View {
        Button {
            
        } label: {
            Image(systemName: "hand.thumbsup.fill")
                .font(.title2)
        }
    }
    
    private func textFieldSmall() -> some View {
        TextField("", text: $text, prompt: Text("Aa"))
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .padding(.trailing, 25)
            .background(.messagesGray)
            .cornerRadius(20)
            .overlay {
                HStack {
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "face.smiling")
                            .font(.title2)
                    }
                    .padding(.trailing, 5)
                }
            }
            .onTapGesture {
                minimumAction = true
            }
    }
    
    private func buttonVoice() -> some View {
        Button {
            
        } label: {
            Image(systemName: "mic.fill")
                .font(.title2)
        }
    }
    
    private func buttonPhoto() -> some View {
        Button {
            
        } label: {
            Image(systemName: "photo")
                .font(.title2)
        }
    }
    
    
    private func buttonCamera() -> some View {
        Button {
            
        } label: {
            Image(systemName: "camera.fill")
                .font(.title2)
        }
    }
    
    private func buttonMore() -> some View {
        Button {
            
        } label: {
            Image(systemName: "plus")
                .padding(4)
                .foregroundStyle(.messagesWhite)
                .background(Color(.systemBlue))
                .clipShape(Circle())
        }
    }
}

#Preview {
    TextInputArea()
}
