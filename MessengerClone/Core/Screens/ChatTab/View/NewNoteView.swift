//
//  NewNoteView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 7/10/24.
//

import SwiftUI

struct NewNoteView: View {
    @FocusState private var isTextFocusState: Bool
    
    @StateObject private var viewModel: NewNoteViewModel
    let handleAction: () -> Void
    
    init(currentNote: NoteItem?, completion: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: NewNoteViewModel(currentNote: currentNote))
        self.handleAction = completion
    }
    
    private var isValidNote: Bool {
        return viewModel.text.isEmpty
    }
    
    var body: some View {
        VStack {
            topView
            Spacer()
            
            mainNote
            Spacer()
            bottomView
        }
        .onAppear {
            isTextFocusState = true
        }
        .sheet(isPresented: $viewModel.isShowMusicPicker) {
            musicPickerSheet
        }
        .sheet(isPresented: $viewModel.isDetailMusic) {
            detailMusic()
        }
    }
    
    /// Music picker sheet
    private var musicPickerSheet: some View {
                
        VStack {
            HStack {
                TextField("", text: $viewModel.textSearch, prompt: Text("Search Music"))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 40)
                    .background(Color(.systemGray4))
                    .clipShape(
                        .rect(cornerRadius: 10)
                    )
                    .overlay {
                        HStack {
                            Button {
                                
                            } label: {
                                Image(systemName: "magnifyingglass")
                            }
                            Spacer()
                            if !viewModel.textSearch.isEmpty {
                                Button {
                                    withAnimation {
                                        viewModel.textSearch = ""
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                }
                            }
                        }
                        .bold()
                        .foregroundStyle(Color(.systemGray))
                        .padding(.horizontal, 10)
                    }
                    .frame(maxWidth: .infinity)
                
                Button("Cancel") {}
            }
            .padding(10)
            
            List {
                ForEach(0..<10) { item in
                    MusicCellView()
                        .onTapGesture {
                            viewModel.isShowMusicPicker = false
                            viewModel.isDetailMusic = true
                        }
                }
            }
            .listStyle(.plain)
            
            Spacer()
        }
        .ignoresSafeArea()
    }
    
    /// Detail music
    private func detailMusic() -> some View {
        NavigationStack {
            VStack {
                VStack(spacing: 8) {
                    Rectangle()
                        .frame(width: 60, height: 60)
                        .clipShape(
                            .rect(cornerRadius: 10)
                        )
                    
                    Text("Die with A Smile")
                        .bold()
                        .font(.title3)
                        .padding(.top, 5)
                    
                    Text("Lady Gaga, Bruno Mars")
                        .foregroundStyle(Color(.systemGray))
                        .font(.subheadline)
                }
                .padding(.top, 50)
                
                Spacer()
                
                HStack(spacing: 20) {
                    Image(systemName: "30.circle")
                        .font(.title2)
                        .padding(10)
                        .background(Color(.systemGray3))
                        .clipShape(Circle())
                    
                    ZStack {
                        Rectangle()
                            .frame(width: viewModel.mainRectangleWidth)
                            .frame(height: 4)
                            .foregroundStyle(Color(.systemGray4))
                            .clipShape(Capsule())
                        
                        HStack {
                            Rectangle()
                                .frame(width: viewModel.smallRectangleWidth)
                                .frame(height: 4)
                                .foregroundStyle(Color(.white))
                                .clipShape(Capsule())
                                .offset(x: viewModel.scrollOffsetXMusic)
                                .padding(.leading, 14.7714285714)
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    Image(systemName: "play.fill")
                        .font(.title2)
                        .padding(13)
                        .background(Color(.systemGray3))
                        .clipShape(Circle())
                }
                .padding(.horizontal, 30)
                
                /// This is the bottom bar
                ZStack {
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                ForEach(0..<150) { rect in
                                    HStack(spacing: 5) {
                                        Rectangle()
                                            .frame(width: 2, height: 8)
                                            .foregroundStyle(Color(.systemGray4))
                                            .clipShape(Capsule())
                                        Rectangle()
                                            .frame(width: 2, height: 15)
                                            .foregroundStyle(Color(.systemGray4))
                                            .clipShape(Capsule())
                                    }
                                    .padding(.trailing, 5)
                                    .id(rect)
                                }
                            }
                            .background(
                                GeometryReader { geo -> Color in
                                    DispatchQueue.main.async {
                                        viewModel.scrollOffsetXMusic = -((geo.frame(in: .global).minX) / viewModel.times)
                                    }
                                    return Color.clear
                                }
                            )
                            .padding(.horizontal, (UIScreen.main.bounds.width / 2) - 60)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                    }
                    
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.blue, lineWidth: 4)
                        .frame(width: 120, height: 50)
                        .foregroundStyle(.clear)
                }
            }
            .presentationDragIndicator(.visible)
            .presentationDetents([.medium])
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        
                    }
                }
            }
        }
    }
    
    /// Main note
    private var mainNote: some View {
        VStack(spacing: 10) {
            ZStack {
                CircularProfileImage(viewModel.currentUser?.profileImage, size: .xLarge)
                                
                bubbleNote
            }
            .frame(width: 200)
            
            Text("\(viewModel.text.count)/\(viewModel.characterLimit)")
                .font(.callout)
                .foregroundStyle(Color(.systemGray2))
            
            Button {
                viewModel.isShowMusicPicker = true
            } label: {
                Image(systemName: "music.quarternote.3")
                    .padding()
                    .foregroundStyle(.white)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
                    .bold()
            }
        }
    }
    
    /// Bubble Note
    private var bubbleNote: some View {
        VStack(alignment: .leading) {
            textFieldView
                .shadow(color: Color(.black).opacity(0.45), radius: 1, x: 0, y: 1)
            Circle()
                .frame(width: 20, height: 20)
                .foregroundStyle(Color(.systemGray5))
                .padding(.leading, 25)
                .padding(.top, -20)
            Circle()
                .frame(width: 10, height: 10)
                .foregroundStyle(Color(.systemGray5))
                .padding(.leading, 35)
                .padding(.top, -8)
        }
        .offset(y: -60)
    }
    
    /// Text Field View
    private var textFieldView: some View {
        ZStack {
            Text(viewModel.text)
                .padding()
                .background(Color(.systemGray5))
                .clipShape(
                    .rect(cornerRadius: 20)
                )
                .focused($isTextFocusState)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("", text: $viewModel.text, prompt: Text("Share a thought..."))
                .padding()
                .background(Color(.systemGray5))
                .clipShape(
                    .rect(cornerRadius: 20)
                )
                .focused($isTextFocusState)
                .multilineTextAlignment(.center)
                .opacity(viewModel.text.isEmpty ? 1 : 0)
                .frame(width: 200)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onChange(of: viewModel.text) { oldValue, newValue in
                    /// Limit character of the text
                    viewModel.text = String(viewModel.text.prefix(viewModel.characterLimit))
                }
        }
    }
    
    /// Top Navigation Bar
    private var topView: some View {
        ZStack {
            HStack {
                Button {
                    handleAction()
                } label: {
                    Image(systemName: "xmark")
                }
                Spacer()
                Button("Share") {
                    viewModel.createANote()
                    handleAction()
                }
                .disabled(isValidNote)
            }
            .font(.headline)
            Text("New note")
                .bold()
        }
        .padding(10)
    }
    
    /// Bottom View
    private var bottomView: some View {
        VStack {
            Text("Friends can see your note for 24 hours.")
                .foregroundStyle(Color(.systemGray2))
            Text("Change audience")
                .foregroundStyle(.blue)
        }
        .font(.footnote)
        .bold()
        .padding(.bottom, 10)
    }
}

struct MusicCellView: View {
    
    @State private var playing: Bool = false
    
    var body: some View {
        Button {
            
        } label: {
            HStack {
                Rectangle()
                    .frame(width: 70, height: 70)
                    .clipShape(
                        .rect(cornerRadius: 10)
                    )
                
                VStack(alignment: .leading) {
                    Text("Name Song")
                        .bold()
                    Text("Author the song")
                        .foregroundStyle(Color(.systemGray))
                }
                
                Spacer()
                
                Button {
                    withAnimation {
                        playing.toggle()
                    }
                } label: {
                    Image(systemName: playing ? "pause.fill" : "play.fill")
                        .font(.footnote)
                        .foregroundStyle(Color(.white))
                        .padding(8)
                        .background(Color(.systemGray3))
                        .clipShape(Circle())
                }
            }
        }
    }
}

#Preview {
    NewNoteView(currentNote: .stubNote) {
        
    }
}
