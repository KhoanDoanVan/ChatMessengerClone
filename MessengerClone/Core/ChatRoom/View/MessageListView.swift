//
//  MessageListView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 9/8/24.
//

import Foundation
import SwiftUI

struct MessageListView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = MessageListController
    private var viewModel: ChatRoomScreenViewModel
    private var blurViewModel = BlurViewModel()
    
    init(_ viewModel: ChatRoomScreenViewModel) {
        self.viewModel = viewModel
    }
    
    func makeUIViewController(context: Context) -> MessageListController {
        let messageListController = MessageListController(viewModel, blurViewModel)
        return messageListController
    }
    
    func updateUIViewController(_ uiViewController: MessageListController, context: Context) { }
}
