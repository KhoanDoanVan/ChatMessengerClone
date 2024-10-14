//
//  URL+Extension.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 14/10/24.
//

import Foundation

extension URL {
    /// Get size of the file
    func getFileSize() -> Int64? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: self.path)
            if let fileSize = attributes[.size] as? Int64 {
                return fileSize
            }
        } catch {
            print("Error to retrieving file size \(error.localizedDescription)")
        }
        return nil
    }
}
