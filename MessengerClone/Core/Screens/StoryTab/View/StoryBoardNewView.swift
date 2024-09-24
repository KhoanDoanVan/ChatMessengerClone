//
//  StoryBoardNewView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 24/9/24.
//

import SwiftUI

struct StoryBoardNewView: View {
    
    let uiImage: UIImage?
    
    var body: some View {
        VStack {
            ZStack {
                topBar()
                
                if let uiImage = uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGray6))
            .safeAreaPadding(.top)
            .clipShape(
                .rect(cornerRadius: 20)
            )
            Spacer()
            bottomBar()
        }
    }
    
    /// Top bar
    private func topBar() -> some View {
        VStack {
            HStack {
                Button {
                    
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.white)
                        .bold()
                        .font(.title2)
                }
                Spacer()
                HStack {
                    Button {
                        
                    } label: {
                        Image(systemName: "scribble.variable")
                            .foregroundStyle(.white)
                            .bold()
                            .font(.title2)
                    }
                    Button {
                        
                    } label: {
                        Image(systemName: "textformat")
                            .foregroundStyle(.white)
                            .bold()
                            .font(.title2)
                    }
                    Button {
                        
                    } label: {
                        Image(systemName: "face.smiling")
                            .foregroundStyle(.white)
                            .bold()
                            .font(.title2)
                    }
                    Button {
                        
                    } label: {
                        Image(systemName: "scissors")
                            .foregroundStyle(.white)
                            .bold()
                            .font(.title2)
                    }
                    Button {
                        
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(.white)
                            .bold()
                            .font(.title2)
                    }
                }
            }
            .padding(.horizontal)
            Spacer()
        }
    }
    
    /// Bottom bar
    private func bottomBar() -> some View {
        HStack {
            Button {
                
            } label: {
                VStack(spacing: 10) {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                    Text("Settings")
                        .font(.footnote)
                }
                .foregroundStyle(.white)
            }
            Spacer()
            
            Button {
                
            } label: {
                Text("Add to story")
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                    .font(.footnote)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 15)
                    .background(.white)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
}

#Preview {
    StoryBoardNewView(uiImage: .messengerIcon)
}
