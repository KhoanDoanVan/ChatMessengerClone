//
//  BubbleLocationView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 23/9/24.
//


import SwiftUI
import MapKit

struct BubbleLocationView: View {
    
    let message: MessageItem
    let isShowAvatarSender: Bool
    var latitude: CLLocationDegrees?
    var longtitude: CLLocationDegrees?
    
    @Binding var bubbleMessageDidSelect: MessageItem?
    
    let handleAction: (_ state: Bool, _ message: MessageItem) -> Void
    
    @State private var cameraPosition : MapCameraPosition = .region(.userRegionFarmore)
    
    /// State to manage the scale of the bubble
    @State private var isScaled = false
    
    init(message: MessageItem, isShowAvatarSender: Bool,
         bubbleMessageDidSelect: Binding<MessageItem?>, handleAction: @escaping (_: Bool, _: MessageItem) -> Void) {
        self.message = message
        self.isShowAvatarSender = isShowAvatarSender
        self.handleAction = handleAction
        self._bubbleMessageDidSelect = bubbleMessageDidSelect
        self.cameraPosition = cameraPosition
        
        if let location = message.location {
            self.latitude = location.latitude
            self.longtitude = location.longtitude
        }
    }
    
    var body: some View {
        HStack(alignment: .bottom) {
            if message.isNotMe && isShowAvatarSender {
                CircularProfileImage(message.sender?.profileImage ,size: .xSmall)
            } else if message.isNotMe {
                VStack {
                    
                }
                .frame(width: 40, height: 40)
            }
            
            if message.isNotMe {
                ZStack {
                    HStack {
                        bubbleMap()
                            .scaleEffect(isScaled ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.35), value: isScaled)
                            .onAppear {
                                if bubbleMessageDidSelect?.messageReply?.id == message.id {
                                    scaleUpAndReset()
                                }
                            }
                            .padding(.horizontal, message.emojis != nil && message.isNotMe == false ? -8 : 0)
                        Spacer()
                    }
                    
                    if message.emojis != nil {
                        HStack {
                            VStack {
                                Spacer()
                                buttonReaction()
                                    .padding(.vertical, -15)
                                    .padding(.horizontal, 8)
                            }
                            Spacer()
                        }
                    }
                }
            } else {
                ZStack {
                    HStack {
                        Spacer()
                        bubbleMap()
                            .scaleEffect(isScaled ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.35), value: isScaled)
                            .onAppear {
                                if bubbleMessageDidSelect?.messageReply?.id == message.id {
                                    scaleUpAndReset()
                                }
                            }
                            .padding(.horizontal, 0)
                    }
                    
                    if message.emojis != nil && message.isNotMe == false {
                        HStack {
                            Spacer()
                            VStack {
                                Spacer()
                                buttonReaction()
                                    .padding(.vertical, -15)
                                    .padding(.horizontal, 8)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: message.alignment)
        .padding(.leading, message.leadingPadding)
        .padding(.trailing, message.trailingPadding)
        .padding(.bottom, message.emojis != nil ? 25 : 0)
        .onChange(of: bubbleMessageDidSelect ?? .stubMessageText) { oldSelectedMessage,newSelectedMessage in
            if newSelectedMessage.messageReply?.id == message.id {
                scaleUpAndReset()
            }
        }
    }
    
    /// Setup scale with dispatchQueue
    private func scaleUpAndReset() {
        // Scale up
        withAnimation {
            isScaled = true
        }
        
        // After 1 second, reset the scale back to normal
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                isScaled = false
                bubbleMessageDidSelect = nil
            }
        }
    }
    
    /// Button Reaction
    private func buttonReaction() -> some View {
        Button {
            handleAction(true, message)
        } label: {
            HStack(spacing: 3) {
                ForEach(0..<min(message.emojis?.count ?? 0, 3), id: \.self) { index in
                    Text(message.emojis?[index].reaction ?? "")
                        .font(.footnote)
                }
                
                if (message.emojis?.count ?? 0) > 1 {
                    Text("\(message.emojis?.count ?? 0)")
                        .font(.footnote)
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal,8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color(.systemGray2)) // Main background
            )
            .overlay(
                Capsule()
                    .stroke(Color.black, lineWidth: 4) // Black stroke effect
            )
            .clipShape(Capsule())
        }
        .padding(.top)
    }
    
    /// Bubble Map
    private func bubbleMap() -> some View {
        VStack(spacing: 0) {
            if let latitude = latitude, let longitude = longtitude {
                Map(position: $cameraPosition) {
                    Annotation(
                        "",
                        coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    ) {
                        ZStack {
                            Circle()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.black)
                                .clipShape(Circle())
                                .overlay {
                                    Image(systemName: "location.fill")
                                        .font(.footnote)
                                        .foregroundStyle(.white)
                                }
                        }
                    }
                }
                .frame(width: 250, height: 150)
                .disabled(true)
                
                VStack(alignment: .leading) {
                    Text("Pinned location")
                        .bold()
                        .foregroundStyle(.white)
                    Text(message.location?.nameAddress ?? "Unknown")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.5))
                }
                .frame(width: 250)
                .padding(10)
                .background(Color(.systemGray5))
            } else {
                Text("Location not available")
                    .foregroundStyle(.gray)
            }
        }
        .frame(width: 250)
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
    }
}

//#Preview {
//    BubbleLocationView(message: .stubMessageTextIsMe, isShowAvatarSender: false) { state, message in
//        
//    }
//}
