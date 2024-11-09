//
//  MusicItem.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 6/11/24.
//

struct MusicItem: Decodable, Identifiable {
    let id: String
    let title: String
    let artist: String
    let thumbnailUrl: String
    let audioUrl: String
    
    init(fromDictionary dict: [String: Any]) {
        self.id = dict["id"] as? String ?? ""
        self.title = dict["title"] as? String ?? ""
        self.artist = dict["artist"] as? String ?? ""
        self.thumbnailUrl = dict["thumbnailUrl"] as? String ?? ""
        self.audioUrl = dict["audioUrl"] as? String ?? ""
    }

}

extension MusicItem {
    func toDictionary() -> [String: Any] {
        return [
            "id": self.id,
            "title": self.title,
            "artist": self.artist,
            "thumbnailUrl": self.thumbnailUrl,
            "audioUrl": self.audioUrl
        ]
    }
}
