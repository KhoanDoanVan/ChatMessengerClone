//
//  Int64+Extension.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 14/10/24.
//

import Foundation


extension Int64 {
    
    /// Transform to string
    func toStringSizeOfFile() -> String {
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
        byteCountFormatter.countStyle = .file
        return byteCountFormatter.string(fromByteCount: self)
    }
}
