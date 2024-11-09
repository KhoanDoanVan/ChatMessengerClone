//
//  Test.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 9/11/24.
//


import SwiftUI
import AVFoundation

struct AudioFromLevelsView: View {
    @State private var audioEngine = AVAudioEngine()
    @State private var audioPlayerNode = AVAudioPlayerNode()
    let levels: [Float] = [0.2, 0.4, 0.6, 0.8, 1.0, 0.8, 0.6, 0.4, 0.2]
    let sampleRate: Float = 44100.0
    let frequency: Float = 440.0
    
    var body: some View {
        VStack {
            Text("Play synthesized Audio")
                .font(.title)
            Button {
                
            } label: {
                Text("Play")
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(Color.white)
                    .clipShape(
                        .rect(cornerRadius: 8)
                    )
            }
        }
        .onAppear {
            
        }
    }
    
    func playAudio() {
        let buffer = createAudioBuffer()
        
        
        audioEngine.attach(audioPlayerNode)
        audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: buffer.format)
        
        do {
            try audioEngine.start()
        } catch {
            print("Audio Engine failed to start: \(error.localizedDescription)")
        }
        
        audioPlayerNode.scheduleBuffer(buffer, at: nil, options: .loops)
        audioPlayerNode.play()
    }
    
    func createAudioBuffer() -> AVAudioPCMBuffer {
        let durationPerLevel: Float = 0.1
        let totalSamples = Int(sampleRate * durationPerLevel * Float(levels.count))
        
        let format = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(totalSamples))
        
        buffer?.frameLength = AVAudioFrameCount(totalSamples)
        
        let bufferPointer = buffer?.floatChannelData![0]
        
        
        var sampleIndex = 0
        for level in levels {
            for i in 0..<Int(sampleRate * durationPerLevel) {
                let t = Float(i) / sampleRate
                bufferPointer![sampleIndex] = level * sin(2 * .pi * frequency * t)
                sampleIndex += 1
            }
        }
        
        return buffer!
    }
}

#Preview {
    AudioFromLevelsView()
}
