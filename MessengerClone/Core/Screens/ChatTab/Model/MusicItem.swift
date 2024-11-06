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
}
