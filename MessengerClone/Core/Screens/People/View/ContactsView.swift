//
//  ContactsView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 8/8/24.
//

import SwiftUI

struct ContactsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var searchable: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(0..<12) { _ in
                        contactColumn()
                    }
                }
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .navigationTitle("Contacts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                buttonTrailing()
            }
            .searchable(
                text: $searchable,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search contacts"
            )
        }
    }
    
    private func contactColumn() -> some View {
        HStack {
            Circle()
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("User name")
                    .fontWeight(.bold)
                Text("Facebook")
                    .font(.footnote)
                    .foregroundStyle(Color(.systemGray))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension ContactsView {
    @ToolbarContentBuilder
    private func buttonTrailing() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                dismiss()
            } label: {
                Text("Done")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContactsView()
    }
}
