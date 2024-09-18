//
//  PeopleScreen.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 8/8/24.
//

import SwiftUI

struct PeopleScreen: View {
    
    @Binding var showSidebarScreen: Bool
    @State private var showContacts: Bool = false
    
    init(showSidebarScreen: Binding<Bool>) {
        self._showSidebarScreen = showSidebarScreen
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    suggestedSection()
                    facebookUpdateSection()
                    activeNowSection()
                }
                .scrollIndicators(.hidden)
                .listStyle(.plain)
            }
            .navigationTitle("People")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                leadingButton()
                trailingButton()
            }
            .sheet(isPresented: $showContacts, content: {
                ContactsView()
            })
        }
    }
}

extension PeopleScreen {
    
    private func activeNowSection() -> some View {
        Section {
            
            ForEach(0..<12) { _ in
                HStack {
                    Circle()
                        .frame(width: 50, height: 50)
                    
                    Text("User name")
                        .fontWeight(.bold)
                }
            }
        } header: {
            Text("Active now (120)")
        }
    }
    
    private func suggestedSection() -> some View {
        Section {
            HStack {
                Circle()
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading) {
                    Text("User name")
                        .fontWeight(.bold)
                    Text("400K members")
                        .foregroundStyle(Color(.systemGray))
                        .font(.footnote)
                }
                
                Spacer()
                
                Image(systemName: "checkmark")
                    .foregroundStyle(Color(.systemBlue))
            }
        } header: {
            Text("Suggested communities")
        }
    }
    
    private func facebookUpdateSection() -> some View {
        Section {
            HStack {
                Circle()
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading) {
                    Text("User name")
                        .fontWeight(.bold)
                    Text("Added a new photo")
                        .font(.footnote)
                        .foregroundStyle(Color(.systemGray))
                }
                
                Spacer()
                
                Image(systemName: "checkmark")
                    .foregroundStyle(Color(.systemBlue))
            }
        } header: {
            HStack {
                Text("Facebook updates")
                Spacer()
                Button {
                    
                } label: {
                    Text("See more")
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    private func leadingButton() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                showSidebarScreen.toggle()
            } label: {
                Image(systemName: "list.bullet")
                    .fontWeight(.bold)
            }
        }
    }
    
    @ToolbarContentBuilder
    private func trailingButton() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showContacts.toggle()
            } label: {
                Image(systemName: "person.crop.rectangle.stack")
                    .fontWeight(.bold)
            }
        }
    }
}

#Preview {
    NavigationStack {
        PeopleScreen(showSidebarScreen: .constant(false))
    }
}
