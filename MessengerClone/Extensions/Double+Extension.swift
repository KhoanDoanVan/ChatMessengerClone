//
//  Double+Extension.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 26/8/24.
//

import Foundation

extension Double {
    var formatDurationDoubleToString: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
