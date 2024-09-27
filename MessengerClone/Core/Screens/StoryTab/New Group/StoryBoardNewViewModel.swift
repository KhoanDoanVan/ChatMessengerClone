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

struct SBText: Hashable, Identifiable {
    let id: String = UUID().uuidString
    var content: String = ""
    var alignment: TextAlignment = .center
    var background: Bool = false
    var color: Color = .white
    var dropLocationText: CGPoint = .zero
    
    // Custom Hashable implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(id) // Use 'id' as the unique identifier for hashing
    }

    // Implement Equatable manually for comparing SBText instances
    static func ==(lhs: SBText, rhs: SBText) -> Bool {
        return lhs.id == rhs.id
    }
}

@MainActor
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
    @Published var isGestureText: Bool = false
    @Published var textCurrent: SBText = SBText()
    @Published var textSelectedColor: Color = .white
    @Published var centerGeometry: CGPoint = .zero
    @Published var draggedItem: String?
    @Published var isDragging: Bool = false
    @Published var texts: [SBText] = [SBText]()
}
