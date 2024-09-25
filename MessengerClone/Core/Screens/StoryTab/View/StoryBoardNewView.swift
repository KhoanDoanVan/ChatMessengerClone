//
//  StoryBoardNewView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 24/9/24.
//

import SwiftUI
import UIKit

struct StoryBoardNewView: View {
        
    @State private var isActionDraw: Bool = false
    @State private var isGesture: Bool = false
    @State private var selectedColor: Color = .white
    @State private var thinkness: Double = 3.0
    
    @State private var currentLine: Line = Line()
    @State private var lines: [Line] = [Line]()
    @State private var eraserLines: [Line] = [Line]()
    
    var body: some View {
        VStack {
            ZStack {
                
                Canvas { context, size in
                    for line in lines {
                        var path = Path()
                        path.addLines(line.points)
                        context.stroke(path, with: .color(line.color), lineWidth: line.lineWidth)
                    }
                }
                .gesture(
                    isActionDraw 
                    ? DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged({ value in
                            let newPoint = value.location
                            currentLine.points.append(newPoint)
                            self.lines.append(currentLine)
                            
                            isGesture = true
                        })
                        .onEnded({ value in
                            self.currentLine = Line(points: [], color: selectedColor, lineWidth: thinkness)
                            
                            isGesture = false
                        })
                    : nil
                )
                
                if isActionDraw {
                    if !isGesture {
                        VStack {
                            HStack {
                                if !lines.isEmpty {
                                    Text("Undo")
                                        .bold()
                                        .foregroundStyle(.white)
                                    .onTapGesture {
                                        if !lines.isEmpty {
                                            lines.removeLast()
                                        }
                                    }
                                }
                                Spacer()
                                Button {
                                    withAnimation {
                                        isActionDraw.toggle()
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
                } else {
                    topBar()
                }
                
                if isActionDraw {
                    if !isGesture {
                        HStack {
                            UISliderView(
                                value: $thinkness,
                                minValue: 1.0,
                                maxValue: 20.0,
                                thumbColor: .white,
                                minTrackColor: .white.withAlphaComponent(0.6),
                                maxTrackColor: .white.withAlphaComponent(0.6)
                            )
                            .onChange(of: thinkness) { oldValue, newValue in
                                currentLine.lineWidth = newValue
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGray6))
            .safeAreaPadding(.top)
            .clipShape(
                .rect(cornerRadius: 20)
            )
            Spacer()
            
            if isActionDraw {
                if !isGesture {
                    barColor()
                        .padding(.bottom, 10)
                }
            } else {
                bottomBar()
                    .padding(.horizontal)
                    .padding(.bottom, 10)
            }
        }
    }
    
    /// Top bar
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
                            isActionDraw.toggle()
                        }
                    } label: {
                        Image(systemName: "scribble.variable")
                            .foregroundStyle(.white)
                            .bold()
                            .font(.title2)
                    }
                    Button {
                        
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
    
    /// Bottom bar
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
    
    /// Bar Color
    private func barColor() -> some View {
        HStack {
            Button {
                selectedColor = Color(.systemGray6)
            } label: {
                Image(systemName: "eraser.fill")
                    .foregroundStyle(selectedColor == Color(.systemGray6) ? .black : .white)
                    .font(.title3)
                    .padding(8)
                    .background(selectedColor == Color(.systemGray6) ? .white : .black)
                    .clipShape(Circle())
            }
            .padding(.horizontal, 5)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(ColorPickerConstants.listColorPicker, id: \.self) { color in
                        Button {
                            selectedColor = color
                        } label: {
                            if selectedColor == color {
                                Circle()
                                    .stroke(.white, lineWidth: selectedColor == color ? 10 : 0)
                                    .stroke(.black, lineWidth: selectedColor == color ? 3 : 0)
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
                    .onChange(of: selectedColor) { oldValue, newValue in
                        currentLine.color = newValue
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 8)
            }
        }
        .frame(height: 50)
    }
}

#Preview {
    StoryBoardNewView()
}
