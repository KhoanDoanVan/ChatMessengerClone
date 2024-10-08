//
//  StoryBoardNewViewModel.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 25/9/24.
//

import Foundation
import SwiftUI
import Combine

struct SBLine {
    var points: [CGPoint] = [CGPoint]()
    var color: Color = .white
    var lineWidth: Double = 3.0
}

struct SBText: Hashable, Identifiable {
    let id: String = UUID().uuidString
    var content: String = ""
    var alignment: TextAlignment = .center
    var background: Bool = false
    var color: Color = .white
    var dropLocationText: CGPoint = .zero
    
    // Custom Hashable implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(id) // Use 'id' as the unique identifier for hashing
    }

    // Implement Equatable manually for comparing SBText instances
    static func ==(lhs: SBText, rhs: SBText) -> Bool {
        return lhs.id == rhs.id
    }
}

struct SBSticker: Identifiable {
    let id: String = UUID().uuidString
    var image: UIImage = UIImage()
    var width: Double = 0
    var dropLocationSticker: CGPoint = .zero
}

@MainActor
class StoryBoardNewViewModel: ObservableObject {
    
    // MARK: - Properties
    @Published var listStickers: [StickerItem]?
    @Published var centerGeometry: CGPoint = .zero
    
    // MARK: - Draw Action
    @Published var isActionDraw: Bool = false
    @Published var isGesture: Bool = false
    @Published var selectedColor: Color = .white
    @Published var thinkness: Double = 3.0
    @Published var currentLine: SBLine = SBLine()
    @Published var lines: [SBLine] = [SBLine]()
    @Published var eraserLines: [SBLine] = [SBLine]()
    
    // MARK: - Text
    @Published var isActionText: Bool = false
    @Published var isGestureText: Bool = false
    @Published var textCurrent: SBText = SBText()
    @Published var textSelectedColor: Color = .white
//    @Published var draggedItem: String?
    @Published var isDraggingText: Bool = false
    @Published var texts: [SBText] = [SBText]()
    
    // MARK: - Sticker
    @Published var isShowSheetSticker: Bool = false
    @Published var stickerCurrent: SBSticker = SBSticker()
    @Published var stickers: [SBSticker] = [SBSticker]()
    @Published var isDraggingSticker: Bool = false
    
    // MARK: - Upload
    @Published var uiImage: UIImage?
    
    /// Show Sticker Picker
    func showStickerPicker() {
        self.isShowSheetSticker.toggle()
        
        if listStickers == nil {
            fetchStickers() { stickers in
                if let stickers = stickers {
                    self.listStickers = stickers
                } else {
                    print("fetchStickerError Failed")
                }
            }
        }
    }
    
    /// Fetch Stickers
    func fetchStickers(completion: @escaping ([StickerItem]?) -> Void) {
        guard let url = URL(string: "https://api.mojilala.com/v1/stickers/trending?api_key=dc6zaTOxFJmzC") else {
            print("URL Not Exactly")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to fetch data: \(String(describing: error?.localizedDescription))")
                completion(nil)
                return
            }
            
            do {
                let stickerResponse = try JSONDecoder().decode(Welcome.self, from: data)
                completion(stickerResponse.data) // No optional chaining needed here
            } catch {
                print("Failed to decode JSON: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    /// Add sticker to list sticker
    func addSticker(_ sticker: StickerItem) {
        let url = sticker.images.fixedHeight.url
        
        guard let url = URL(string: url) else {
            print("Invalid URL sticker")
            return
        }
                
        fetchImage(url) { uiImage in            
            DispatchQueue.main.async {
                let sticker = SBSticker(image: uiImage ?? UIImage(), width: 100, dropLocationSticker: self.centerGeometry)
                self.stickers.append(sticker)
            }
        }
    }
    
    /// Fetch image
    func fetchImage(_ url: URL, completion: @escaping (UIImage?) -> Void) {
                
        URLSession.shared.dataTask(with: url) { data, response, error in
                        
            guard let data, error == nil
            else {
                print("Error fetching image: \(String(describing: error?.localizedDescription))")
                completion(nil)
                return
            }
            
            
            let image = UIImage(data: data)
            
            completion(image)
        }.resume()
    }
    
    /// upload image story
    private func uploadImageStoryToStorage(_ uiImage: UIImage? ,completion: @escaping (URL?) -> Void) {
        
        guard let uiImage else { return }
        
        FirebaseHelper.uploadImagePhoto(uiImage, for: .photoStory) { result in
            switch result {
                
            case .success(let imageUrl):
                completion(imageUrl)
            case .failure(let failure):
                completion(nil)
                print("Failure uploadImageToStorage with error: \(failure.localizedDescription)")
            }
        } progressHandler: { progress in
            print("Progress uploadImageToStorage: \(progress)")
        }
    }
    
    /// create new story
    func createStory(_ uiImage: UIImage?) {
        uploadImageStoryToStorage(uiImage) { url in
            guard let url else { return }
            
            StoryService.createNewStory(url) {
                print("Upload Story Success")
            }
        }
    }
}
