//
//  StoryBoardNewView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 24/9/24.
//

import SwiftUI
import UIKit
import Kingfisher
import Photos

struct StoryBoardNewView: View {
    
    @ObservedObject private var viewModel = StoryBoardNewViewModel()
    @FocusState private var isTextFieldFocused: Bool
    
    let handleAction: () -> Void
    
    var body: some View {
        VStack {
            ZStack {
                mainView()
                    .padding(.top, 10)
                
                drawTopBar()
                    .padding(.top)
            }
            
            Spacer()
            
            if viewModel.isActionDraw {
                if !viewModel.isGesture {
                    barColor()
                        .padding(.bottom, 10)
                }
            } else if viewModel.isActionText {
                textBarColor()
                    .padding(.bottom, 10)
            } else if viewModel.isDraggingText {
                
            }
            else {
                bottomBar()
                    .padding(.horizontal)
                    .padding(.bottom, 10)
            }
        }
        .sheet(isPresented: $viewModel.isShowSheetSticker) {
            SheetStickerView(listStickers: $viewModel.listStickers) { sticker in
                viewModel.addSticker(sticker)
            }
        }
    }
    
    // Helper function to save the image to Photos
    private func saveImageToPhotos(_ image: UIImage?) {
        guard let image = image else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }

    
    /// Main View
    private func mainView() -> some View {
        ZStack {
            canvasView()
            drawSlider()
            
            geometryView()
            
            textField()
        }
        .dropDestination(for: String.self) { items, location in
            if viewModel.isDraggingText {
                if let draggedId = items.first {
                    if let index = viewModel.texts.firstIndex(where: { $0.id == draggedId }) {
                        viewModel.texts[index].dropLocationText = CGPoint(x: location.x, y: location.y)
                    }
                }
                
                viewModel.isGestureText = false
            }
            
            if viewModel.isDraggingSticker {
                if let draggedId = items.first {
                    if let index = viewModel.stickers.firstIndex(where: { $0.id == draggedId }) {
                        viewModel.stickers[index].dropLocationSticker = CGPoint(x: location.x, y: location.y)
                    }
                }
            }
                            
            return true
        }
        .frame(maxWidth: .infinity, maxHeight: 670)
        .background(Color(.systemGray6))
        .safeAreaPadding(.top)
        .clipShape(
            .rect(cornerRadius: 20)
        )
    }
    
    /// Geometry View
    private func geometryView() -> some View {
        GeometryReader { geotry in
            
            Color.clear
                .onAppear {
                    if viewModel.centerGeometry == .zero {
                        viewModel.centerGeometry = CGPoint(x: geotry.size.width / 2, y: geotry.size.height / 2)
                    }
                }
            
            // MARK: Texts Display
            if !viewModel.texts.isEmpty {
                ForEach(viewModel.texts) { textItem in
                    Text(textItem.content)
                        .font(.system(size: 24))
                        .padding(8)
                        .foregroundStyle(textItem.color)
                        .background(textItem.background ? Color.gray.opacity(0.2) : Color.clear)
                        .cornerRadius(8)
                        .position(textItem.dropLocationText)
                        .draggable(textItem.id) {
                            Text(textItem.content)
                                .font(.system(size: 24))
                                .padding(8)
                                .foregroundStyle(textItem.color)
                                .background(textItem.background ? Color.gray.opacity(0.2) : Color.clear)
                                .cornerRadius(8)
                                .position(textItem.dropLocationText)
                                .onAppear {
                                    viewModel.isDraggingText = true
                                }
                        }
                        .onChange(of: textItem.dropLocationText) { oldLocation, newLocation in
                            handleTextPositionChange(for: textItem, newLocation: newLocation)
                            viewModel.isDraggingText = false
                        }
                }
            }
            
            // MARK: Stickers Display
            if !viewModel.stickers.isEmpty {
                ForEach(viewModel.stickers) { stickerItem in
                    Image(uiImage: stickerItem.image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: stickerItem.width)
                        .frame(height: stickerItem.width)
                        .position(stickerItem.dropLocationSticker)
                        .draggable(stickerItem.id) {
                            Image(uiImage: stickerItem.image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: stickerItem.width)
                                .frame(height: stickerItem.width)
                                .position(stickerItem.dropLocationSticker)
                                .onAppear {
                                    viewModel.isDraggingSticker = true
                                }
                        }
                        .onChange(of: stickerItem.dropLocationSticker) { oldLocation, newLocation in
                            viewModel.isDraggingSticker = false
                        }
                }
            }
                                
            if viewModel.isDraggingText {
                Rectangle()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.clear)
                    .overlay {
                        Image(systemName: "trash.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(.black)
                            .clipShape(Circle())
                    }
                    .position(CGPoint(x: geotry.size.width / 2, y: geotry.size.height - 40))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 670)
    }
    
    /// Handle Change in Text Position
    private func handleTextPositionChange(for textItem: SBText, newLocation: CGPoint) {
        if (newLocation.x <= 236.5 && newLocation.x >= 156.5) && (newLocation.y <= 650 && newLocation.y >= 570) {
            if let index = viewModel.texts.firstIndex(where: { $0.id == textItem.id }) {
                viewModel.texts.remove(at: index)
            }
        }
        viewModel.isDraggingText = false
    }
    
    /// Main Canvas
    private func canvasView() -> some View {
        Canvas { context, size in
            // Draw lines
            for line in viewModel.lines {
                var path = Path()
                path.addLines(line.points)
                context.stroke(path, with: .color(line.color), lineWidth: line.lineWidth)
            }
        }
        .gesture(
            viewModel.isActionDraw
            ? DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged({ value in
                    let newPoint = value.location
                    viewModel.currentLine.points.append(newPoint)
                    viewModel.lines.append(viewModel.currentLine)
                    
                    viewModel.isGesture = true
                })
                .onEnded({ value in
                    viewModel.currentLine = SBLine(points: [], color: viewModel.selectedColor, lineWidth: viewModel.thinkness)
                    
                    viewModel.isGesture = false
                })
            : nil
        )
    }
    
    /// Draw Top Bar
    @ViewBuilder
    private func drawTopBar() -> some View {
        if viewModel.isActionDraw {
            if !viewModel.isGesture {
                VStack {
                    HStack {
                        if !viewModel.lines.isEmpty {
                            Text("Undo")
                                .bold()
                                .foregroundStyle(.white)
                            .onTapGesture {
                                if !viewModel.lines.isEmpty {
                                    viewModel.lines.removeLast()
                                }
                            }
                        }
                        Spacer()
                        Button {
                            withAnimation {
                                viewModel.isActionDraw.toggle()
                            }
                        } label: {
                            Text("Done")
                                .bold()
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.horizontal)
                    Spacer()
                }
            }
        } else if viewModel.isActionText {
            if !viewModel.isGestureText {
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            withAnimation {
                                viewModel.isActionText.toggle()
                                viewModel.textCurrent.dropLocationText = viewModel.centerGeometry
                                viewModel.texts.append(viewModel.textCurrent)
                                viewModel.textCurrent = SBText()
                            }
                        } label: {
                            Text("Done")
                                .bold()
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.horizontal)
                    Spacer()
                }
            }
        } else if viewModel.isDraggingText {
            
        }
        else {
            topBar()
        }
    }
    
    /// Draw Slider
    @ViewBuilder
    private func drawSlider() -> some View {
        if viewModel.isActionDraw {
            if !viewModel.isGesture {
                HStack {
                    UISliderView(
                        value: $viewModel.thinkness,
                        minValue: 1.0,
                        maxValue: 20.0,
                        thumbColor: .white,
                        minTrackColor: .white.withAlphaComponent(0.6),
                        maxTrackColor: .white.withAlphaComponent(0.6)
                    )
                    .onChange(of: viewModel.thinkness) { oldValue, newValue in
                        viewModel.currentLine.lineWidth = newValue
                    }
                    .frame(width: 250)
                    .tint(.white.opacity(0.8))
                    .rotationEffect(.degrees(-90))
                    .offset(x: -90)
                    .shadow(color: .black.opacity(0.85), radius: 10)
                    
                    Spacer()
                }
            }
        }
    }
    
    /// Draw Bar Color
    private func barColor() -> some View {
        HStack {
            Button {
                viewModel.selectedColor = Color(.systemGray6)
            } label: {
                Image(systemName: "eraser.fill")
                    .foregroundStyle(viewModel.selectedColor == Color(.systemGray6) ? .black : .white)
                    .font(.title3)
                    .padding(8)
                    .background(viewModel.selectedColor == Color(.systemGray6) ? .white : .black)
                    .clipShape(Circle())
            }
            .padding(.horizontal, 5)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(ColorPickerConstants.listColorPicker, id: \.self) { color in
                        Button {
                            viewModel.selectedColor = color
                        } label: {
                            if viewModel.selectedColor == color {
                                Circle()
                                    .stroke(.white, lineWidth: viewModel.selectedColor == color ? 10 : 0)
                                    .stroke(.black, lineWidth: viewModel.selectedColor == color ? 3 : 0)
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(.white.opacity(0.8))
                                    .overlay {
                                        Circle()
                                            .frame(width: 21, height: 21)
                                            .foregroundStyle(color)
                                    }
                            } else {
                                Circle()
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(.white.opacity(0.8))
                                    .overlay {
                                        Circle()
                                            .frame(width: 21, height: 21)
                                            .foregroundStyle(color)
                                    }
                            }
                        }
                        .padding(.horizontal, 5)
                    }
                    .onChange(of: viewModel.selectedColor) { oldValue, newValue in
                        viewModel.currentLine.color = newValue
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 8)
            }
        }
        .frame(height: 50)
    }
    
    /// TextField
    @ViewBuilder
    private func textField() -> some View {
        if viewModel.isActionText {
            ZStack {
                if !viewModel.textCurrent.content.isEmpty {
                    HStack {
                        if viewModel.textCurrent.alignment == .trailing {
                            Spacer()
                        }
                        
                        Text(viewModel.textCurrent.content)
                            .font(.system(size: 24))
                            .padding(8)
                            .foregroundStyle(viewModel.textCurrent.color)
                            .background(viewModel.textCurrent.background ? Color.gray.opacity(0.2) : Color.clear)
                            .cornerRadius(8)
                        
                        if viewModel.textCurrent.alignment == .leading {
                            Spacer()
                        }
                    }
                }
                
                TextField("", text: $viewModel.textCurrent.content)
                    .multilineTextAlignment(viewModel.textCurrent.alignment)
                    .focused($isTextFieldFocused)
                    .foregroundStyle(viewModel.textCurrent.color)
                    .font(.system(size: 24))
                    .opacity(viewModel.textCurrent.content.isEmpty ? 1 : 0)
            }
            .padding(4)
        }
    }
    
    /// Text Bar Color
    @ViewBuilder
    private func textBarColor() -> some View {
        if viewModel.isActionText {
            HStack(spacing: 10) {
                Button {
                    if viewModel.textCurrent.alignment == .center {
                        viewModel.textCurrent.alignment = .leading
                    } else if viewModel.textCurrent.alignment == .leading {
                        viewModel.textCurrent.alignment = .trailing
                    } else {
                        viewModel.textCurrent.alignment = .center
                    }
                } label: {
                    if viewModel.textCurrent.alignment == .center {
                        Image(systemName: "text.aligncenter")
                            .bold()
                            .foregroundStyle(.white)
                            .font(.title2)
                    } else if viewModel.textCurrent.alignment == .leading {
                        Image(systemName: "text.alignleft")
                            .bold()
                            .foregroundStyle(.white)
                            .font(.title2)
                    } else {
                        Image(systemName: "text.alignright")
                            .bold()
                            .foregroundStyle(.white)
                            .font(.title2)
                    }
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(ColorPickerConstants.listColorPicker, id: \.self) { color in
                            Button {
                                viewModel.textSelectedColor = color
                            } label: {
                                if viewModel.textSelectedColor == color {
                                    Circle()
                                        .stroke(.white, lineWidth: viewModel.textSelectedColor == color ? 10 : 0)
                                        .stroke(.black, lineWidth: viewModel.textSelectedColor == color ? 3 : 0)
                                        .frame(width: 25, height: 25)
                                        .foregroundStyle(.white.opacity(0.8))
                                        .overlay {
                                            Circle()
                                                .frame(width: 21, height: 21)
                                                .foregroundStyle(color)
                                        }
                                } else {
                                    Circle()
                                        .frame(width: 25, height: 25)
                                        .foregroundStyle(.white.opacity(0.8))
                                        .overlay {
                                            Circle()
                                                .frame(width: 21, height: 21)
                                                .foregroundStyle(color)
                                        }
                                }
                            }
                            .padding(.horizontal, 5)
                        }
                        .onChange(of: viewModel.textSelectedColor) { oldValue, newValue in
                            viewModel.textCurrent.color = newValue
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 8)
                }
                Button {
                    viewModel.textCurrent.background.toggle()
                } label: {
                    Image(systemName: viewModel.textCurrent.background ? "t.square.fill" : "t.square")
                        .bold()
                        .foregroundStyle(.white)
                        .font(.title)
                }
            }
            .padding(.horizontal)
        }
    }
    
    
    /// Main top bar
    private func topBar() -> some View {
        VStack {
            HStack {
                Button {
                    handleAction()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.white)
                        .bold()
                        .font(.title2)
                }
                Spacer()
                HStack(spacing: 15) {
                    Button {
                        withAnimation {
                            viewModel.isActionDraw.toggle()
                        }
                    } label: {
                        Image(systemName: "scribble.variable")
                            .foregroundStyle(.white)
                            .bold()
                            .font(.title2)
                    }
                    Button {
                        withAnimation {
                            viewModel.isActionText.toggle()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                isTextFieldFocused = true
                            }
                            
                        }
                    } label: {
                        Image(systemName: "textformat")
                            .foregroundStyle(.white)
                            .bold()
                            .font(.title2)
                    }
                    Button {
                        withAnimation {
                            viewModel.showStickerPicker()
                        }
                    } label: {
                        Image(systemName: "face.smiling")
                            .foregroundStyle(.white)
                            .bold()
                            .font(.title2)
                    }
                    Button {
                        let image = SnapshotHelper.takeSnapshot(of: mainView(), size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
                        saveImageToPhotos(image)
                    } label: {
                        Image(systemName: "arrow.down.to.line")
                            .foregroundStyle(.white)
                            .bold()
                            .font(.title2)
                    }
                    Button {
                        
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(.white)
                            .bold()
                            .font(.title2)
                    }
                }
            }
            .padding(.horizontal)
            Spacer()
        }
    }
    
    /// Main bottom bar
    private func bottomBar() -> some View {
        HStack {
            Button {
                
            } label: {
                VStack(spacing: 10) {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                    Text("Settings")
                        .font(.footnote)
                }
                .foregroundStyle(.white)
            }
            Spacer()
            
            Button {
                
            } label: {
                Text("Add to story")
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                    .font(.footnote)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 15)
                    .background(.white)
                    .clipShape(Capsule())
            }
        }
    }
}

#Preview {
    StoryBoardNewView() {
        
    }
}
