//
//  ChatTabScreenViewModel.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 9/8/24.
//

import Foundation


class ChatTabScreenViewModel: ObservableObject {
    
    @Published var openCreateNewMessage = false
    @Published var navigationToChatRoom = false
    
    func createNewChat() {
        openCreateNewMessage = false
        navigationToChatRoom = true
    }
}
