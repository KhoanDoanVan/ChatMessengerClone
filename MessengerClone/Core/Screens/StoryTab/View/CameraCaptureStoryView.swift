//
//  CameraCaptureStoryView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 4/10/24.
//

import Foundation
import SwiftUI
import AVFoundation

struct CameraCaptureStoryView: View {
    
    @StateObject private var viewModel = CameraScreenViewModel()
    
    let handleAction: () -> Void
    
    var body: some View {
        ZStack {
            if !viewModel.isTaken {
                CameraPreview(camera: viewModel)
            }
            
            if !viewModel.isTaken {
                VStack {
                    if viewModel.isTaken {
                        HStack {
                            Button {
                                handleAction()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .bold()
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 10)
                            }
                            .padding(.horizontal, 20)
                            
                            Spacer()
                        }
                    } else {
                        navTop()
                    }
                    
                    Spacer()
                    
                    if !viewModel.isTaken {
                        Button {
                            viewModel.takePicture()
                            viewModel.transformDataToUIImage() { uiImage in
                                print("Uiimage: \(uiImage)")
                            }
                        } label: {
                            Circle()
                                .frame(width: 80, height: 80)
                                .foregroundStyle(.white.opacity(0.5))
                                .overlay {
                                    Circle()
                                        .frame(width: 50, height: 50)
                                        .foregroundStyle(.white)
                                }
                        }
                        .padding(.bottom, 20)
                    }
                }
            } else {
                if let uiImage = viewModel.uiImage {
                    StoryBoardNewView(uiImage: uiImage) { action in
                        
                    }
                }
            }
        }
        .onAppear {
            viewModel.requestCameraAccess()
        }
    }
    
    /// Nav top
    private func navTop() -> some View {
        HStack {
            Button {
                
            } label: {
                Image(systemName: "xmark")
                    .bold()
                    .font(.title3)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
            }
            Spacer()
            HStack(spacing: 20) {
                Button {
                    
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                        .bold()
                        .font(.title3)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                }
                Button {
                    
                } label: {
                    Image(systemName: "bolt.slash.fill")
                        .bold()
                        .font(.title3)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                }
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}
