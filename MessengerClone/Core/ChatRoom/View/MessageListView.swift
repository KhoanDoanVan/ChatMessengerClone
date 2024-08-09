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
    
    func makeUIViewController(context: Context) -> MessageListController {
        let messageListController = MessageListController()
        return messageListController
    }
    
    func updateUIViewController(_ uiViewController: MessageListController, context: Context) { }
}
