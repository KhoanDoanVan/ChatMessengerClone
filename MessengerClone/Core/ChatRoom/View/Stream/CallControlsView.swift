//
//  CallControlsView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 18/9/24.
//

import SwiftUI
import StreamVideo
import StreamVideoSwiftUI

struct CallControlsView: View {
    
    @ObservedObject var viewModel: StreamCallViewModel
    
    let handleLeaveStream: (_ timeVideoCall: TimeInterval) -> Void
    
    var body: some View {
        HStack(spacing: 24) {
            Button {
                Task {
                    try await viewModel.controlCamera()
                }
            } label: {
                Image(systemName: "video.fill")
                    .font(.title2)
                    .foregroundStyle(viewModel.camera ?? false ? .white : Color(.systemGray))
            }
            
            Spacer()
            
            Button {
                Task {
                    try await viewModel.controlMicrophone()
                }
            } label: {
                Image(systemName: "mic.fill")
                    .font(.title2)
                    .foregroundStyle(viewModel.microphone ?? false ? .white : Color(.systemGray))
            }
            
            Spacer()
            
            Button {
                Task {
                    try await viewModel.controlSpeaker()
                }
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                    .font(.title2)
                    .foregroundStyle(viewModel.speaker ?? false ? .white : Color(.systemGray))
            }
            
            Spacer()
            
            leaveStreamButton()
        }
        .foregroundStyle(.white)
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(Color(.systemGray2))
        .clipShape(Capsule())
        .padding(.horizontal, 16)
    }
    
    private func leaveStreamButton() -> some View {
        Button {
            viewModel.leaveStream()
            handleLeaveStream(viewModel.timeVideoCall)
        } label: {
            Image(systemName: "phone.down.fill")
                .padding()
                .foregroundStyle(.white)
                .font(.title2)
                .background(Color(.systemRed))
                .clipShape(Circle())
        }
    }
}

struct BackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15, *) {
            content
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: 24)
                )
        } else {
            content
                .background(Color.black.opacity(0.8))
                .cornerRadius(24)
        }
    }
}
