//
//  PickerPhotoView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 23/8/24.
//

import SwiftUI

struct PickerPhotoView: View {
    
    @Binding var listAttachment: [MediaAttachment]
    @Binding var listAttachmentPicker: [MediaAttachment]
    let handleActionPicker: (_ action: TextInputArea.UserAction) -> Void
    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3),
    ]
    
    let widthImage = ((UIWindowScene.current?.screenWidth ?? 0) - 9) / 4

    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 3 ,content: {
                    ForEach(listAttachment, id: \.self) { attachment in
                        gridCellImage(attachment)
                    }
                })
            }
            
            buttonSendImages()
        }
        .padding(.vertical, 5)
    }
    
    /// Grid Cell Image
    private func gridCellImage(_ attachment: MediaAttachment) -> some View {
        Button {
            handleActionPicker(.pickerAttachment(attachment))
        } label: {
            Image(uiImage: attachment.thumbnail)
                .resizable()
                .frame(width: widthImage)
                .frame(height: 100)
                .scaledToFill()
                .overlay(alignment: .bottomTrailing) {
                    if let durationVideo = attachment.durationVideo {
                        Text(durationVideo.formatElaspedTime)
                            .bold()
                            .font(.system(size: 12))
                            .padding(.horizontal, 3)
                            .foregroundStyle(.white)
                    }
                }
        }
        .frame(width: widthImage)
        .frame(height: 100)
        .overlay {
            if listAttachmentPicker.contains(where: { $0.id == attachment.id}) {
                Rectangle()
                    .frame(width: widthImage)
                    .frame(height: 100)
                    .foregroundStyle(.white)
                    .opacity(0.5)
            }
        }
        .overlay {
            
            if listAttachmentPicker.contains(where: { $0.id == attachment.id}) {
                Text("\((listAttachmentPicker.firstIndex(where: {$0.id == attachment.id}) ?? 0) + 1)")
                    .padding(10)
                    .background(Color(.systemBlue))
                    .clipShape(Circle())
            }
        }
    }
    
    /// Button Send
    @ViewBuilder
    private func buttonSendImages() -> some View {
        if !listAttachmentPicker.isEmpty {
            VStack {
                Spacer()
                
                Button {
                    handleActionPicker(.sendImagesMessage)
                } label: {
                    Text("SEND \(listAttachmentPicker.count)")
                        .foregroundStyle(.white)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(.systemBlue))
                        .cornerRadius(20)
                }
                .padding()
                .padding(.vertical, 10)
                .shadow(color: .black.opacity(0.3), radius: 5)
            }
        }
    }
}

#Preview {
    PickerPhotoView(listAttachment: .constant([]), listAttachmentPicker: .constant([])) { _ in
        
    }
}
