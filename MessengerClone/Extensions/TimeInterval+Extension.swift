//
//  TimeInterval+Extension.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 26/8/24.
//

import Foundation

extension TimeInterval {
    var formatElaspedTime: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Convert TimeInterval to a human-readable string
    func formattedTimeDurationVideoCall() -> String {
        let totalSeconds = Int(self)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        if minutes > 0 {
            if seconds > 0 {
                return "\(minutes) mins, \(seconds) secs"
            } else {
                return "\(minutes) mins"
            }
        } else {
            return "\(seconds) secs"
        }
    }
}
