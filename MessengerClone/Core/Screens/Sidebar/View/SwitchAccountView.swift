//
//  SwitchAccountView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 8/8/24.
//

import SwiftUI

struct SwitchAccountView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section {
                        columnAccount()
                        columnAccount()
                    }
                    
                    Section {
                        buttonAddAccount()
                    }
                }
                .listStyle(.plain)
                
                Divider()
                
                buttonCreateNewAccount()
            }
            .navigationTitle("Switch account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                buttonDone()
            }
        }
    }
    
    private func columnAccount() -> some View {
        HStack {
            Circle()
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading) {
                Text("User name")
                    .fontWeight(.bold)
                Text("Signed in")
                    .font(.footnote)
            }
            
            Spacer()
            
            Image(systemName: "checkmark")
                .foregroundStyle(Color(.systemBlue))
        }
    }
}

extension SwitchAccountView {
    
    private func buttonCreateNewAccount() -> some View {
        Button {
            
        } label: {
            Text("Create new account")
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(.systemBlue))
                .cornerRadius(15)
                .padding([.leading,.trailing,.bottom], 10)
        }
    }
    
    private func buttonAddAccount() -> some View {
        HStack {
            Image(systemName: "plus")
                .font(.title)
                .padding(10)
                .foregroundStyle(.white)
                .background(Color(.systemGray3))
                .clipShape(Circle())
            Text("Add account")
                .fontWeight(.bold)
        }
        .listRowSeparator(.hidden)
    }
    
    @ToolbarContentBuilder
    private func buttonDone() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                dismiss()
            } label: {
                Text("Done")
                    .fontWeight(.bold)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SwitchAccountView()
    }
}
