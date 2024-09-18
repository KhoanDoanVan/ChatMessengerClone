//
//  String+Extension.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 16/8/24.
//

import Foundation

extension String {
    var isEmptyOrWhiteSpace: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
