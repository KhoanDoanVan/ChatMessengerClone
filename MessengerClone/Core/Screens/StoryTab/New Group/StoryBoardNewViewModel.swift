//
//  StoryBoardNewViewModel.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 25/9/24.
//

import Foundation
import SwiftUI

struct SBLine {
    var points: [CGPoint] = [CGPoint]()
    var color: Color = .white
    var lineWidth: Double = 3.0
}

struct SBText {
    var content: String = ""
    var alignment: TextAlignment = .center
    var background: Bool = false
    var color: Color = .white
}

class StoryBoardNewViewModel: ObservableObject {
    
    // MARK: - Draw Action
    @Published var isActionDraw: Bool = false
    @Published var isGesture: Bool = false
    @Published var selectedColor: Color = .white
    @Published var thinkness: Double = 3.0
    @Published var currentLine: SBLine = SBLine()
    @Published var lines: [SBLine] = [SBLine]()
    @Published var eraserLines: [SBLine] = [SBLine]()
    
    // MARK: - Text
    @Published var isActionText: Bool = false
    @Published var text: SBText = SBText()
    @Published var textSelectedColor: Color = .white
}
