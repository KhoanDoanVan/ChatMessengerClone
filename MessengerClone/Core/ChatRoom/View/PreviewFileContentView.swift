//
//  PreviewFileContentView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 15/10/24.
//

import SwiftUI

struct PreviewFileContentView: View {
    
    let content: String
    let fileName: String
    let urlFileDownloaded: String
    let handleAction: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(.vertical) {
                    Text(content)
                        .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle(fileName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                buttonTrailling
                buttonBottom
            }
        }
    }
    
    /// Trailing button
    private var buttonTrailling: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Done") {
                handleAction()
            }
        }
    }
    
    /// Trailing button
    private var buttonBottom: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            HStack {
                ShareLink(item: URL(string: urlFileDownloaded)!) {
                    Image(systemName: "square.and.arrow.up")
                }
                Spacer()
                Button {
                    
                } label: {
                    Image(systemName: "magnifyingglass")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PreviewFileContentView(content: "", fileName: "", urlFileDownloaded: "") {
            
        }
    }
}
