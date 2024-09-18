//
//  CircularProfileImage.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 14/8/24.
//

import SwiftUI
import Kingfisher

struct CircularProfileImage: View {
    
    let profileImageURL: String?
    let size: Size
    let fallbackImage: FallbackImage
    let arrayUrl: [String?]
    
    var sizeCircleBubble: CGFloat {
        if size.dimension == Size.xMedium.dimension {
            return Size.small.dimension
        } else if size.dimension == Size.xSmall.dimension {
            return Size.xMini.dimension
        } else if size.dimension == Size.xLarge.dimension {
            return Size.large.dimension
        }
        else {
            return Size.mini.dimension
        }
    }
    
    init(_ profileImageURL: String? = nil, size: Size) {
        self.profileImageURL = profileImageURL
        self.size = size
        self.fallbackImage = .directChannel
        self.arrayUrl = []
    }
    
    var body: some View {
        if let profileImageURL {
            KFImage(URL(string: profileImageURL))
                .resizable()
                .placeholder {
                    ProgressView()
                }
                .scaledToFill()
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(Circle())
        } else if fallbackImage == .groupChannel {
            imageGroupView(sizeCircleBubble, array: arrayUrl)
        }
        else {
            Image("userDefaultFB")
                .resizable()
                .scaledToFill()
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(Circle())
        }
    }
}

extension CircularProfileImage {
    init(_ channelItem: ChannelItem, size: Size) {
        self.profileImageURL = nil
        self.size = size
        self.fallbackImage = channelItem.membersCount == 2 ? .directChannel : .groupChannel
        self.arrayUrl = channelItem.listImageForThumbnail
    }
    
    private func imageGroupView(_ sizeCircleBubble: CGFloat, array: [String?]) -> some View {
        
        ZStack {
            HStack {
                Spacer()
                VStack {
                    ZStack {
                        Circle()
                            .frame(width: sizeCircleBubble + 5, height: sizeCircleBubble + 5)
                            .foregroundStyle(.messagesWhite)
                        
                        imageCircleGroup(imageUrl: array[0])
                    }
                    Spacer()
                }
            }
            HStack {
                VStack {
                    Spacer()
                    ZStack {
                        Circle()
                            .frame(width: sizeCircleBubble + 5, height: sizeCircleBubble + 5)
                            .foregroundStyle(.messagesWhite)
                        imageCircleGroup(imageUrl: array[1])
                    }

                }                
                Spacer()
            }
        }
        .padding(0)
        .frame(width: size.dimension, height: size.dimension)
    }
    
    @ViewBuilder
    private func imageCircleGroup(imageUrl: String?) -> some View {
        if let imageUrl = imageUrl {
            KFImage(URL(string: imageUrl))
                .resizable()
                .placeholder {
                    ProgressView()
                }
                .scaledToFill()
                .frame(width: sizeCircleBubble, height: sizeCircleBubble)
                .clipShape(Circle())
        } else {
            Image("userDefaultFB")
                .resizable()
                .scaledToFill()
                .frame(width: sizeCircleBubble, height: sizeCircleBubble)
                .clipShape(Circle())
        }
    }
}

extension CircularProfileImage {
    
    enum FallbackImage: String {
        case directChannel
        case groupChannel
    }
    
    enum Size {
        case xMini, mini, xSmall, small, medium, xMedium, large, xLarge
        case custom(CGFloat)
        
        var dimension: CGFloat {
            switch self {
            case .xMini:
                return 25
            case .mini:
                return 30
            case .xSmall:
                return 40
            case .small:
                return 50
            case .medium:
                return 60
            case .xMedium:
                return 75
            case .large:
                return 80
            case .xLarge:
                return 120
            case .custom(let dimen):
                return dimen
            }
        }
    }
}

#Preview {
    CircularProfileImage(.placeholder, size: .xLarge)
}
