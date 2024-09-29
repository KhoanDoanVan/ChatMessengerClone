//
//  SnapHelper.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 29/9/24.
//

import SwiftUI


struct SnapshotHelper {
    static func takeSnapshot(of content: some View, size: CGSize) -> UIImage? {
        let controller = UIHostingController(rootView: content)
        let view = controller.view

        view?.bounds = CGRect(origin: .zero, size: size)
        view?.backgroundColor = .systemGray6

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            view?.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
        }
    }
}
