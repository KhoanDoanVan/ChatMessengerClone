//
//  SheetStickerView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 28/9/24.
//

import SwiftUI
import Kingfisher

struct SheetStickerView: View {
    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    @Binding var listStickers: [StickerItem]?
    
    let handleActionPickerSticker: (_ sticker: StickerItem) -> Void
    
    let widthSicker = ((UIWindowScene.current?.screenWidth ?? 0) - 50) / 3
    
    var body: some View {
        NavigationStack {
            VStack {
                if let listStickers = listStickers {
                    ScrollView(.vertical ) {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(listStickers, id: \.self) { sticker in
                                cellSticker(sticker)
                            }
                        }
                    }
                } else {
                    ProgressView()
                }
            }
        }
    }
    
    /// Cell Sticker
    private func cellSticker(_ sticker: StickerItem) -> some View {
        Button {
            handleActionPickerSticker(sticker)
        } label: {
            KFImage(URL(string: sticker.images.fixedHeight.url))
                .resizable()
                .scaledToFill()
                .frame(width: widthSicker)
                .frame(height: widthSicker)
        }
    }
}

#Preview {
    SheetStickerView(listStickers: .constant([])) { sticker in
        
    }
}
