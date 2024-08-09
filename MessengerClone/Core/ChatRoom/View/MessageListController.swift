//
//  MessageListController.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 9/8/24.
//

import SwiftUI
import UIKit

final class MessageListController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageCollectionView.backgroundColor = .clear
        view.backgroundColor = .clear
        setUpViews()
    }
    
    // MARK: Propertises
    private let cellIdentifier = "MessageListControllerCells"
    
    private let compositionalLayout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
        
        /// Create list
        var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfig.backgroundColor = UIColor.systemBackground
        listConfig.showsSeparators = false
        
        /// Create a section
        let section = NSCollectionLayoutSection.list(using: listConfig, layoutEnvironment: layoutEnvironment)
        section.contentInsets.leading = 0
        section.contentInsets.trailing = 0
        return section
    }
    
    private lazy var messageCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self // always
        collectionView.dataSource = self // always
        collectionView.contentInset = .init(top: 0, left: 0, bottom: 60, right: 0)
        collectionView.scrollIndicatorInsets = .init(top: 0, left: 0, bottom: 60, right: 0)
        collectionView.selfSizingInvalidation = .enabledIncludingConstraints
        collectionView.backgroundColor = .clear
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        return collectionView
    }()
    
    
    private func setUpViews() {
        view.addSubview(messageCollectionView)
        
        NSLayoutConstraint.activate([
            messageCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            messageCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            messageCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

extension MessageListController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    /// Create cell
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        
        cell.backgroundColor = .clear
        cell.contentConfiguration = UIHostingConfiguration(content: {
            BubbleView()
        })
        
        return cell
    }
    
    
}

#Preview {
    MessageListView()
        .ignoresSafeArea()
}
