//
//  StoryBoardNewView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 24/9/24.
//

import SwiftUI
import UIKit

struct StoryBoardNewView: View {
    
    @StateObject private var viewModel = StoryBoardNewViewModel()
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack {
            ZStack {
                canvasView()
                
                drawTopBar()
                drawSlider()
                
                textField()
            }
            .frame(maxWidth: .infinity, maxHeight: 670)
            .background(Color(.systemGray6))
            .safeAreaPadding(.top)
            .clipShape(
                .rect(cornerRadius: 20)
            )
            Spacer()
            
            if viewModel.isActionDraw {
                if !viewModel.isGesture {
                    barColor()
                        .padding(.bottom, 10)
                }
            } else if viewModel.isActionText {
                textBarColor()
                    .padding(.bottom, 10)
            }
            else {
                bottomBar()
                    .padding(.horizontal)
                    .padding(.bottom, 10)
            }
        }
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
            
            // Create the text with the desired font and color
            let formattedText = Text(viewModel.text.content)
                .font(.system(size: 24))
                .foregroundStyle(viewModel.text.color)
            
            // Measure the size of the text
            let textSize = context.resolve(formattedText).measure(in: CGSize(width: size.width, height: size.height))
            
            // Calculate the center position for the text
            let textPosition = CGPoint(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2
            )
            
            // Draw the text on top of the background
            if !viewModel.isActionText {
                if viewModel.text.background {
                    // Draw a rectangle behind the text (this is the background)
                    let backgroundRect = CGRect(
                        origin: CGPoint(x: textPosition.x - 10, y: textPosition.y - 10),  // Add some padding
                        size: CGSize(width: textSize.width + 20, height: textSize.height + 20) // Include padding
                    )
                    
                    /// Corner radius
                    let roundedRectPath = Path(roundedRect: backgroundRect, cornerRadius: 8)
                    
                    context.fill(
                        roundedRectPath,
                        with: .color(Color.gray.opacity(0.2)) // Set the background color and opacity
                    )
                }
                
                context.draw(formattedText, at: textPosition, anchor: .topLeading)
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
            VStack {
                HStack {
                    Spacer()
                    Button {
                        withAnimation {
                            viewModel.isActionText.toggle()
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
                if !viewModel.text.content.isEmpty {
                    HStack {
                        if viewModel.text.alignment == .trailing {
                            Spacer()
                        }
                        
                        Text(viewModel.text.content)
                            .font(.system(size: 24))
                            .padding(8)
                            .foregroundStyle(viewModel.text.color)
                            .background(viewModel.text.background ? Color.gray.opacity(0.2) : Color.clear)
                            .cornerRadius(8)
                        
                        if viewModel.text.alignment == .leading {
                            Spacer()
                        }
                    }
                }
                
                TextField("", text: $viewModel.text.content)
                    .multilineTextAlignment(viewModel.text.alignment)
                    .focused($isTextFieldFocused)
                    .foregroundStyle(viewModel.text.color)
                    .font(.system(size: 24))
                    .opacity(viewModel.text.content.isEmpty ? 1 : 0)
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
                    if viewModel.text.alignment == .center {
                        viewModel.text.alignment = .leading
                    } else if viewModel.text.alignment == .leading {
                        viewModel.text.alignment = .trailing
                    } else {
                        viewModel.text.alignment = .center
                    }
                } label: {
                    if viewModel.text.alignment == .center {
                        Image(systemName: "text.aligncenter")
                            .bold()
                            .foregroundStyle(.white)
                            .font(.title2)
                    } else if viewModel.text.alignment == .leading {
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
                            viewModel.text.color = newValue
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 8)
                }
                Button {
                    viewModel.text.background.toggle()
                } label: {
                    Image(systemName: viewModel.text.background ? "t.square.fill" : "t.square")
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
                        
                    } label: {
                        Image(systemName: "face.smiling")
                            .foregroundStyle(.white)
                            .bold()
                            .font(.title2)
                    }
                    Button {
                        
                    } label: {
                        Image(systemName: "scissors")
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
    StoryBoardNewView()
}
