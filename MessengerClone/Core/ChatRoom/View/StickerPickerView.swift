//
//  StickerPickerView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 20/9/24.
//

import SwiftUI
import Kingfisher

struct StickerPickerView: View {
    
    @Binding var listStickers: [StickerItem]
    let handleActionPickerSticker: (_ action: TextInputArea.UserAction) -> Void
    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3)
    ]
    
    let widthSticker = ((UIWindowScene.current?.screenWidth ?? 0) - 32) / 4
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: columns, spacing: 8, content: {
                ForEach(listStickers, id: \.self) { sticker in
                    cellSticker(sticker)
                }
            })
        }
        .padding(16)
    }
    
    /// Cell Sticker
    private func cellSticker(_ sticker: StickerItem) -> some View {
        Button {
            handleActionPickerSticker(.pickerSticker(sticker))
        } label: {
            KFImage(URL(string: sticker.images.fixedHeight.url))
                .resizable()
                .frame(width: widthSticker)
                .frame(height: 100)
                .scaledToFill()
        }
    }
}

#Preview {
    StickerPickerView(listStickers: .constant([])) { sticker in
        
    }
}
