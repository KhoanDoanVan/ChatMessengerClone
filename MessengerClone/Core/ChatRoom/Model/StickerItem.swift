//
//  StickerItem.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 20/9/24.
//


import Foundation

// MARK: - Welcome
struct Welcome: Codable, Hashable {
    let data: [DataClass]
    let meta: Meta
}

// MARK: - DataClass
struct DataClass: Codable, Hashable {
    
    let id: String
    let isAnimated: Bool
    let url: String
    let rating: String
    let images: Images

    enum CodingKeys: String, CodingKey {
        case id
        case isAnimated = "is_animated"
        case url, rating, images
    }
}

// MARK: - Images
struct Images: Codable, Hashable {
    let fixedHeight: Fixed
    let fixedHeightStill: FixedStill
    let fixedHeightDownsampled, fixedHeightMedium: Fixed
    let fixedHeightMediumStill: FixedStill
    let fixedHeightMediumDownsampled, fixedWidth: Fixed
    let fixedWidthStill: FixedStill
    let fixedWidthDownsampled, fixedWidthMedium: Fixed
    let fixedWidthMediumStill: FixedStill
    let fixedWidthMediumDownsampled, fixedHeightSmall: Fixed
    let fixedHeightSmallStill: FixedStill
    let fixedWidthSmall: Fixed
    let fixedWidthSmallStill: FixedStill

    enum CodingKeys: String, CodingKey, Hashable {
        case fixedHeight = "fixed_height"
        case fixedHeightStill = "fixed_height_still"
        case fixedHeightDownsampled = "fixed_height_downsampled"
        case fixedHeightMedium = "fixed_height_medium"
        case fixedHeightMediumStill = "fixed_height_medium_still"
        case fixedHeightMediumDownsampled = "fixed_height_medium_downsampled"
        case fixedWidth = "fixed_width"
        case fixedWidthStill = "fixed_width_still"
        case fixedWidthDownsampled = "fixed_width_downsampled"
        case fixedWidthMedium = "fixed_width_medium"
        case fixedWidthMediumStill = "fixed_width_medium_still"
        case fixedWidthMediumDownsampled = "fixed_width_medium_downsampled"
        case fixedHeightSmall = "fixed_height_small"
        case fixedHeightSmallStill = "fixed_height_small_still"
        case fixedWidthSmall = "fixed_width_small"
        case fixedWidthSmallStill = "fixed_width_small_still"
    }
}

// MARK: - Fixed
struct Fixed: Codable, Hashable {
    let url: String
    let width, height, size: Int
    let webp: String
    let webpSize: String

    enum CodingKeys: String, CodingKey {
        case url, width, height, size, webp
        case webpSize = "webp_size"
    }

    // Custom decoder to handle both Int and String for webpSize
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = try container.decode(String.self, forKey: .url)
        width = try container.decode(Int.self, forKey: .width)
        height = try container.decode(Int.self, forKey: .height)
        size = try container.decode(Int.self, forKey: .size)
        webp = try container.decode(String.self, forKey: .webp)

        // Handle webpSize as either a String or an Int
        if let webpSizeString = try? container.decode(String.self, forKey: .webpSize) {
            webpSize = webpSizeString
        } else if let webpSizeInt = try? container.decode(Int.self, forKey: .webpSize) {
            webpSize = String(webpSizeInt)
        } else {
            webpSize = "0" // Fallback if neither decoding works
        }
    }
}

// MARK: - FixedStill
struct FixedStill: Codable, Hashable {
    let url: String
    let width, height, size: Int
}

// MARK: - Meta
struct Meta: Codable, Hashable {
    let status: Int
    let msg: String
}

