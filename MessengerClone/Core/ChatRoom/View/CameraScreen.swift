//
//  CameraScreen.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 21/9/24.
//

import SwiftUI
import AVFoundation

struct CameraScreen: View {
    @StateObject var camera = CameraScreenViewModel()
    
    var body: some View {
        ZStack {
            ZStack {
                CameraPreview(camera: camera)
                    .ignoresSafeArea(.all, edges: .all)
                
                VStack {
                    if camera.isTaken {
                        HStack {
                            Button {
                                camera.reTakePicture()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .bold()
                                    .font(.title3)
                                    .foregroundStyle(.white)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            
                            Spacer()
                        }
                    } else {
                        navTop()
                    }
                    
                    Spacer()
                    if camera.isTaken {
                        HStack {
                            Spacer()
                            Button {
                                camera.reTakePicture()
                            } label: {
                                Text("Send")
                                    .bold()
                                    .foregroundStyle(.black)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(.white)
                                    .clipShape(Capsule())
                            }
                            .padding(.bottom, 20)
                            .padding(.vertical, 20)
                        }
                    } else {
                        Button {
                            camera.takePicture()
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
            }
        }
        .onAppear {
            camera.requestCameraAccess()
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
            }
            Spacer()
            HStack(spacing: 20) {
                Button {
                    
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                        .bold()
                        .font(.title3)
                        .foregroundStyle(.white)
                }
                Button {
                    
                } label: {
                    Image(systemName: "bolt.slash.fill")
                        .bold()
                        .font(.title3)
                        .foregroundStyle(.white)
                }
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview Camera View
struct CameraPreview: UIViewRepresentable {
    
    @ObservedObject var camera: CameraScreenViewModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        
        camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.preview)
        
        /// Starting session
        camera.session.startRunning()
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

#Preview {
    CameraScreen()
}
