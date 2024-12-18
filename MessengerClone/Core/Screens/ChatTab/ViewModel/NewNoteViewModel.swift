//
//  NewNoteViewModel.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 8/10/24.
//

import Foundation
import FirebaseAuth
import Combine
import FirebaseFirestore
import FirebaseDatabase
import AVFoundation

struct RectFill {
    var id: String
    var fill: Bool = false
}
struct LevelFill {
    var id: String
    var fill: Bool = false
    var level: Float = 0
}

@MainActor
class NewNoteViewModel: ObservableObject {
    
    @Published var text: String = ""
    var characterLimit: Int = 60
    
    @Published var currentUser: UserItem?
    @Published var currentNote: NoteItem?
    
    /// Music picker
    @Published var listMusics: [MusicItem] = []
    @Published var musicPicked: MusicItem?
    @Published var isShowMusicPicker: Bool = false
    @Published var isDetailMusic: Bool = false
    @Published var textSearch: String = ""
    @Published var scrollOffsetXMusic: CGFloat = 0
    @Published var scrollOffsetXMusicCorrectly: CGFloat = 0
    @Published var mainScrollOffset: CGFloat = 0
    
    @Published var leftVisibleIndex: Int = 0
    @Published var rightVisibleIndex: Int = 0
    
    @Published var idCount: Int = 0
    /// Width of the main rectangle
    let mainRectangleWidth: CGFloat = 220
    /// Width of the second rectangle
    let smallRectangleWidth: CGFloat = 30
    var bottomBarContentWidth: CGFloat = (6 * 150) + (190)
    var leadingPadding: CGFloat = 14.7714285714
    var times: CGFloat {
        print("Times: \(bottomBarContentWidth / 220)")
        return bottomBarContentWidth / 220
    }
    
    /// Animation scroll view to pick interval time audio
    @Published var listLevels: [Float] = []
    @Published var visibleRange: ClosedRange<CGFloat> = 0...0
    @Published var isScrolling = false
    @Published var isPlay: Bool = false
    @Published var rectsFill: [RectFill] = Array(repeating: RectFill(id: UUID().uuidString ,fill: false), count: 18)
    @Published var levelsToPlayList: [Float] = []
    @Published var levelsFill: [LevelFill] = Array(repeating: LevelFill(id: UUID().uuidString ,fill: false), count: 18)
    let totalTime: Double = 5
    let interval: Double = 5 / 18
        
    private var cancellables = Set<AnyCancellable>()
    
    init(currentNote: NoteItem? = nil) {
        self.currentNote = currentNote
        AuthManager.shared.authState
            .sink { [weak self] authState in
                switch authState {
                case .loggedIn(let user):
                    self?.currentUser = user
                default:
                    self?.currentUser = nil
                }
            }
            .store(in: &cancellables)
    }
    
    /// Create A Note
    func createANote() {
        if currentNote != nil {
            guard let idNote = currentNote?.id else { return }
            NoteSevice.changeANote(idNote, text) {
                print("Update a Note Success")
            }
        } else {
            var noteSound: SoundNote?
            if let music = self.musicPicked {
                noteSound = SoundNote(songItem: music, urlSoundNote: "")
            }
            NoteSevice.uploadANote(text, noteSound) {
                print("Create a Note success")
            }
        }
    }
    
    /// Fetch list musics
    func fetchListMusics() {
        self.fetchMusicItems { [weak self] musics in
            self?.listMusics = musics
        }
    }
    
    /// Service fetch musics
    private func fetchMusicItems(completion: @escaping ([MusicItem]) -> Void) {
        
        var musics: [MusicItem] = []
        
        FirebaseConstants.MusicsRef.getDocuments { querySnapshot, error in
            if let error {
                print("Error Fetch Musics: \(error)")
                completion([])
            }
            
            for document in querySnapshot!.documents {
                do {
                    let musicItem = try document.data(as: MusicItem.self)
                    musics.append(musicItem)
                } catch {
                    print("Failed to decode MusicItem: \(error)")
                }
            }
            
            completion(musics)
        }
    }

    /// Download the audio
    func downloadAudio(from url: URL) async -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let localURL = tempDirectory.appendingPathComponent(url.lastPathComponent)
        
        // Download the file to a temporary location
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            try data.write(to: localURL)
            return localURL
        } catch {
            print("Error downloading audio file: \(error.localizedDescription)")
            return nil
        }
    }

    /// Extract Audio Levels
    func extractAudioLevels(from url: URL, desiredLevels: Int = 150) {
//        var audioLevels: [Float] = []
        
        do {
            let audioFile = try AVAudioFile(forReading: url)
            let totalFrames = Int(audioFile.length)
            let framesPerSegment = totalFrames / desiredLevels
            let frameCapacity = AVAudioFrameCount(framesPerSegment)
            let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: frameCapacity)!
            
            for _ in 0..<desiredLevels {
                do {
                    try audioFile.read(into: buffer, frameCount: frameCapacity)
                    guard let floatChannelData = buffer.floatChannelData else { continue }
                    
                    let frameLength = Int(buffer.frameLength)
                    let channelData = floatChannelData.pointee
                    var sumOfSquares: Float = 0.0
                    
                    for i in 0..<frameLength {
                        let sample = channelData[i]
                        sumOfSquares += sample * sample
                    }
                    
                    let meanSquare = sumOfSquares / Float(frameLength)
                    let rms = sqrt(meanSquare)
//                    audioLevels.append(rms)
                    self.listLevels.append(rms)
                    
                } catch {
                    print("Error reading audio buffer: \(error.localizedDescription)")
                    break
                }
            }
            
        } catch {
            print("Error processing audio file: \(error.localizedDescription)")
        }
    }

    /// Get audio levels
    func getAudioLevels(from remoteURLString: String) async {
        
        guard let url = URL(string: remoteURLString) else { return }
        
        if let localURL = await downloadAudio(from: url) {
            extractAudioLevels(from: localURL)
        } else {
            return
        }
    }
}
