//
//  NewNoteView.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 7/10/24.
//

import SwiftUI
import Kingfisher

/// 18 levels
///

struct RectFill {
    var id: String
    var fill: Bool = false
}
struct LevelFill {
    var id: String
    var fill: Bool = false
    var level: Float = 0
}

struct NewNoteView: View {
    @FocusState private var isTextFocusState: Bool
    
    @StateObject private var viewModel: NewNoteViewModel
    let handleAction: () -> Void
    
    @State private var visibleRange: ClosedRange<CGFloat> = 0...0
    @State private var isScrolling = false
    @State private var isPlay: Bool = false
    @State private var rectsFill: [RectFill] = Array(repeating: RectFill(id: UUID().uuidString ,fill: false), count: 18)
    @State private var levelsToPlayList: [Float] = []
    @State private var levelsFill: [LevelFill] = Array(repeating: LevelFill(id: UUID().uuidString ,fill: false), count: 18)
    let totalTime: Double = 5
    let interval: Double = 5 / 18
    
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
        /// Test commit
                
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
            
            if !viewModel.listMusics.isEmpty {
                List {
                    ForEach(viewModel.listMusics) { music in
                        MusicCellView(music: music)
                            .onTapGesture {
                                viewModel.isShowMusicPicker = false
                                viewModel.isDetailMusic = true
                                viewModel.musicPicked = music
                                Task {
                                    await viewModel.getAudioLevels(from: music.audioUrl)
                                }
                            }
                    }
                }
                .listStyle(.plain)
            } else {
                ProgressView()
                    .padding()
            }
            
            Spacer()
        }
        .onAppear {
            viewModel.fetchListMusics()
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    /// Detail music
    private func detailMusic() -> some View {
        NavigationStack {
            VStack {
                VStack(spacing: 8) {
                    KFImage(URL(string: viewModel.musicPicked?.thumbnailUrl ?? ""))
                        .resizable()
                        .frame(width: 60, height: 60)
                        .scaledToFit()
                        .clipShape(
                            .rect(cornerRadius: 10)
                        )
                    
                    Text(viewModel.musicPicked?.title ?? "Unknown")
                        .bold()
                        .font(.title3)
                        .padding(.top, 5)
                    
                    Text(viewModel.musicPicked?.artist ?? "Unknown")
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
                            /// Still apply audio has 45seconds
                            Rectangle()
                                .frame(width: viewModel.smallRectangleWidth)
                                .frame(height: 4)
                                .foregroundStyle(Color(.white))
                                .clipShape(Capsule())
                                .offset(x: viewModel.scrollOffsetXMusic)
                                .padding(.leading, 29)
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    Button {
                        setupRectsFill()
                        buttonFillRectsAction()
                    } label: {
                        Image(systemName: isPlay ? "pause.fill" : "play.fill")
                            .font(.title2)
                            .padding(13)
                            .background(Color(.systemGray3))
                            .clipShape(Circle())
                            .foregroundStyle(.white)
                    }
                }
                .padding(.top, 30)
                .padding(.horizontal, 30)
                
                /// This is the bottom bar
                ZStack {
                    
                    ZStack {
                        /// Fake scrollview
                        ScrollView(.horizontal) {
                            HStack(spacing: 2) {
                                ForEach(0..<132) { levels in
                                    HStack(spacing: 2) {
                                        Rectangle()
                                            .frame(width: 2, height: 8)
                                            .foregroundStyle(Color(.systemGray4))
                                            .clipShape(Capsule())
                                        
                                        Rectangle()
                                            .frame(width: 2, height: 12)
                                            .foregroundStyle(Color(.systemGray4))
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                            .offset(x: viewModel.scrollOffsetXMusicCorrectly)
                        }
                        
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 120, height: 50)
                            .position(x: UIScreen.main.bounds.width / 2, y: 50)
                            .foregroundStyle(Color(.systemGray6))
                    }
                    
                    ZStack {
                        /// Main ScrollView
                        ScrollViewReader { proxy in
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 0) {
                                    ForEach(viewModel.listLevels.indices, id: \.self) { index in
                                        let level = viewModel.listLevels[index]
                                        let isLeftVisible = index < viewModel.leftVisibleIndex
                                        let isRightVisible = index > viewModel.rightVisibleIndex
                                                            
                                        
                                        HStack(spacing: 5) {
                                            Rectangle()
                                                .frame(width: 2, height: !isLeftVisible || !isRightVisible ? CGFloat(level) * 100 : 12)
                                                .clipShape(Capsule())
                                                .foregroundStyle(isLeftVisible || isRightVisible ? .clear : Color(.systemGray4))
                                        }
                                        .padding(.trailing, 5)
                                        .id(index)
                                    }
                                }
                                .background(
                                    GeometryReader { geo -> Color in
                                        DispatchQueue.main.async {
                                            viewModel.scrollOffsetXMusic = -((geo.frame(in: .global).minX) / viewModel.times)
                                            viewModel.scrollOffsetXMusicCorrectly = geo.frame(in: .global).minX
                                            viewModel.mainScrollOffset = -geo.frame(in: .global).minX
                                            
                                            let visibleWidth = 120
                                            viewModel.leftVisibleIndex = Int((Int(viewModel.mainScrollOffset + 205) - visibleWidth / 2) / 7)
                                            viewModel.rightVisibleIndex = Int((Int(viewModel.mainScrollOffset + 205) + visibleWidth / 2) / 7)
                                            print("LeftIndex: \(viewModel.leftVisibleIndex), RightIndex: \(viewModel.rightVisibleIndex)")
                                        }
                                        
                                        return Color.clear
                                    }
                                )
                                .padding(.horizontal, (UIScreen.main.bounds.width / 2) - 60)

                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 80)
                        }
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.blue, lineWidth: 4)
                            .frame(width: 120, height: 50)
                            .foregroundStyle(.clear)
                        
                        if isPlay {
                            HStack(spacing: 0) {
                                ForEach(0..<18) { index in
                                    Rectangle()
                                        .frame(width: 120/18, height: 50)
                                        .foregroundStyle(rectsFill[index].fill ? Color.blue : .clear)
                                }
                            }
                            
                            HStack(spacing: 0) {
                                ForEach(0..<18) { index in
                                    HStack(spacing: 5) {
                                        Rectangle()
                                            .frame(width: 2, height: CGFloat(levelsFill[index].level) * 100)
                                            .clipShape(Capsule())
                                            .foregroundStyle(levelsFill[index].fill ? .white : .clear)
                                    }
                                    .padding(.trailing, 5)
                                }
                            }
                            .frame(width: 120, height: 50)
                            .padding(.leading, 10)
                        }
                        
                        
                    }

                }
            }
            .presentationDragIndicator(.visible)
            .presentationDetents([.medium])
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        viewModel.isDetailMusic = false
                        viewModel.listLevels = []
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        viewModel.isDetailMusic = false
                        viewModel.listLevels = []
                    }
                }
            }
        }
    }
    
    /// Setup Rectangle fill
    private func setupRectsFill() {
        var index: Int = 0
        for i in viewModel.leftVisibleIndex..<viewModel.rightVisibleIndex {
            rectsFill[index].id = "\(i)"
            levelsFill[index].id = "\(i)"
            levelsFill[index].level = viewModel.listLevels[i]
            index += 1
        }
    }
    
    /// Start Filling Rectangles
    private func buttonFillRectsAction() {
        if !isPlay {
            isPlay = true
            for i in 0..<rectsFill.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * interval) {
                    withAnimation(.easeInOut(duration: interval)) {
                        rectsFill[i].fill = true
                        levelsFill[i].fill = true
                    }
                    if i == rectsFill.count - 1 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                            isPlay = false
                            resetFillRects()
                        }
                    }
                }
            }
        } else {
            isPlay = false
            resetFillRects()
        }
    }
    
    /// Reset Rectangles
    private func resetFillRects() {
        self.rectsFill = Array(repeating: RectFill(id: UUID().uuidString ,fill: false), count: 18)
        self.levelsFill = Array(repeating: LevelFill(id: UUID().uuidString ,fill: false), count: 18)
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

// MARK: - Music Cell View
struct MusicCellView: View {
    
    let music: MusicItem
    @State private var playing: Bool = false
    
    var body: some View {
        Button {
            
        } label: {
            HStack {
                KFImage(URL(string: music.thumbnailUrl))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .clipShape(
                        .rect(cornerRadius: 10)
                    )
                
                VStack(alignment: .leading) {
                    Text(music.title)
                        .bold()
                    Text(music.artist)
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
