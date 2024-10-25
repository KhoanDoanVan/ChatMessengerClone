//
//  MessageListController.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 9/8/24.
//

import SwiftUI
import UIKit
import Combine

final class MessageListController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageCollectionView.backgroundColor = .clear
        view.backgroundColor = .clear
        setUpViews()
        setUpMessagesListener()
        setUpLongTapGesture()
    }
    
    init(
        _ viewModel: ChatRoomScreenViewModel,
        _ blurViewModel: BlurViewModel
    ) {
        self.viewModel = viewModel
        self.blurViewModel = blurViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Propertises
    private let viewModel: ChatRoomScreenViewModel
    private let cellIdentifier = "MessageListControllerCells"
    private var subscription = Set<AnyCancellable>()
    private var lastScrollPosition: String?
    
    // MARK: ViewModel
    private let blurViewModel: BlurViewModel
    
    // MARK: Interface emoji Frame
    private var blurEmojiView: UIVisualEffectView?
    private var startingEmojiFrame: CGRect?
    private var focusedEmojiView: UIView?
    private var highlightEmojiCell: UICollectionViewCell?
    
    // MARK: HOST View Controller
    private var reactionHostViewController: UIViewController?
    private var menuHostViewController: UIViewController?
    
    private lazy var pullToRefresh: UIRefreshControl = {
        let pullToRefreshControl = UIRefreshControl()
        pullToRefreshControl.addTarget(self, action: #selector(pullToRefreshAction), for: .valueChanged)
        return pullToRefreshControl
    }()
    
    private let compositionalLayout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
        
        /// Create list
        var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfig.backgroundColor = UIColor.systemBackground
        listConfig.showsSeparators = false
        
        /// Create a section
        let section = NSCollectionLayoutSection.list(using: listConfig, layoutEnvironment: layoutEnvironment)
        section.contentInsets.leading = 0
        section.contentInsets.trailing = 0
        section.interGroupSpacing = -10
        return section
    }
    
    /// Message Collection view
    private lazy var messageCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self // always
        collectionView.dataSource = self // always
        collectionView.contentInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.selfSizingInvalidation = .enabledIncludingConstraints
        collectionView.backgroundColor = .clear
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.refreshControl = pullToRefresh
        return collectionView
    }()
    
    /// Message Button Scroll to bottom
    private var buttonScrollToBottom: UIButton = {
        var buttonBottom = UIButton(type: .system)
        let chevronImage = UIImage(systemName: "chevron.down")
        buttonBottom.setImage(chevronImage, for: .normal)
        buttonBottom.backgroundColor = UIColor.systemGray6
        buttonBottom.tintColor = UIColor.white
        buttonBottom.layer.cornerRadius = 20
        buttonBottom.translatesAutoresizingMaskIntoConstraints = false
        buttonBottom.widthAnchor.constraint(equalToConstant: 40).isActive = true
        buttonBottom.heightAnchor.constraint(equalToConstant: 40).isActive = true
        buttonBottom.isHidden = true
        buttonBottom.isEnabled = false
        
        buttonBottom.layer.shadowColor = UIColor.black.cgColor
        buttonBottom.layer.shadowOpacity = 0.75 // Adjust the opacity as needed
        buttonBottom.layer.shadowOffset = CGSize(width: 0, height: 1) // Offset for shadow
        buttonBottom.layer.shadowRadius = 1
        
        buttonBottom.addTarget(self, action: #selector(scrollToBottom), for: .touchUpInside)
        
        return buttonBottom
    }()
    
    /// Set up Views
    private func setUpViews() {
        view.addSubview(messageCollectionView)
        view.addSubview(buttonScrollToBottom)
        
        NSLayoutConstraint.activate([
            messageCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            messageCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            messageCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        NSLayoutConstraint.activate([
            buttonScrollToBottom.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonScrollToBottom.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    /// Set up messages listener
    private func setUpMessagesListener() {
        let delay = 200
        
        /// Messages
        viewModel.$messages
            .debounce(for: .milliseconds(delay), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.messageCollectionView.reloadData()
            }
            .store(in: &subscription)
        
        /// Scroll To Bottom
        viewModel.$scrollToBottom
            .debounce(for: .milliseconds(delay), scheduler: DispatchQueue.main)
            .sink { [weak self] scrollRequest in
                if scrollRequest.scroll {
                    self?.messageCollectionView.scrollToLastItem(at: .bottom, animated: scrollRequest.isAnimate)
                }
            }
            .store(in: &subscription)
        
        /// Action after fetch pagination, scroll to the last message i've been fetched
        viewModel.$paginating
            .debounce(for: .milliseconds(delay), scheduler: DispatchQueue.main)
            .sink { [weak self] paginating in
                guard let self,
                      let lastScrollPosition
                else { return }
                
                if paginating == false {
                    guard let index = viewModel.messages.firstIndex(where: {
                        $0.id == lastScrollPosition
                    }) else { return }
                    
                    let indexPath = IndexPath(item: index, section: 0)
                    self.messageCollectionView.scrollToItem(at: indexPath,at: .top, animated: false)
                    self.pullToRefresh.endRefreshing()
                }
            }
            .store(in: &subscription)
    }
    
    /// Call scroll to bottom in viewModel
    @objc private func scrollToBottom() {
        if viewModel.messages.count > 10 {
            self.messageCollectionView.scrollToLastItem(at: .bottom, animated: true)
        }
    }
    
    /// Pull to refresh
     @objc private func pullToRefreshAction() {
         lastScrollPosition = viewModel.messages.first?.id
         viewModel.paginationMoreMessage()
    }
    
    /// Setup Long Tap Gesture
    private func setUpLongTapGesture() {
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(showContextMenu))
        longTapGesture.minimumPressDuration = 0.5
        messageCollectionView.addGestureRecognizer(longTapGesture)
    }
    
    /// Show context Emoji and Menu
    @objc private func showContextMenu(_ gesture: UILongPressGestureRecognizer) {
        
        /// Avoid duplicate call this function twice times
        guard gesture.state == .began else { return }
        
        /// Get the point of the screen
        let point = gesture.location(in: messageCollectionView)
        guard let indexPath = messageCollectionView.indexPathForItem(at: point) else { return }
        
        /// MessageItem
        let message = viewModel.messages[indexPath.item]
        
        if message.unsentIsContainMe {
            return
        }
        
        /// Select cell
        guard let selectedCell = messageCollectionView.cellForItem(at: indexPath) else { return }
        
        /// save the original frame of selectedCell has just clicked (postion xy , frame xy)
        startingEmojiFrame = selectedCell.superview?.convert(selectedCell.frame, to: nil)
        
        /// capture selectedView current into snapshotView
        guard let snapshotEmojiCell = selectedCell.snapshotView(afterScreenUpdates: false) else { return }
        
        /// main frame for display the reaction will bubble the main chat room view
        focusedEmojiView = UIView(frame: startingEmojiFrame ?? .zero)
        guard let focusedEmojiView else { return }
        focusedEmojiView.isUserInteractionEnabled = false
        
        /// set up tap dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissContext))
        
        /// blur view
        let blurEmojiEffect = UIBlurEffect(style: .regular)
        blurEmojiView = UIVisualEffectView(effect: blurEmojiEffect)
        guard let blurEmojiView else { return }
        blurEmojiView.contentView.isUserInteractionEnabled = true
        blurEmojiView.contentView.addGestureRecognizer(tapGesture)
        blurEmojiView.alpha = 0
        
        /// assign highlightedCell for fix the junky bug when dismiss the reaction
        highlightEmojiCell = selectedCell
        highlightEmojiCell?.alpha = 0
        
        /// get key window is entire window screen
        guard let keyWindow = UIWindowScene.current?.keyWindow
        else { return }
        
        /// at view into keyWindow
        keyWindow.addSubview(blurEmojiView)
        keyWindow.addSubview(focusedEmojiView)
        focusedEmojiView.addSubview(snapshotEmojiCell)
        
        /// cover blur entire the screen
        blurEmojiView.frame = keyWindow.frame
        
        /// Attach emoji and menu
        attachEmojiAndMenu(
            to: message,
            in: keyWindow
        )
        
        let shrinkCell = shrinkCell(blurViewModel.startingFrame?.height ?? 0)
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn) {
           
            blurEmojiView.alpha = 1
            
            /// set frame for object into keyWindow
            focusedEmojiView.center.y = keyWindow.center.y - 60 // set the focused view center y-axis
            snapshotEmojiCell.frame = focusedEmojiView.bounds
            /// Scale
            if shrinkCell {
                focusedEmojiView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }
        }
    }
    
    /// Dismiss Emoji Frame
    @objc func dismissContext() {
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 1,
            options: .curveEaseOut
        ) { [weak self] in
            guard let self else { return }
            focusedEmojiView?.transform = .identity
            
            focusedEmojiView?.frame = startingEmojiFrame ?? .zero
            reactionHostViewController?.view.removeFromSuperview()
            menuHostViewController?.view.removeFromSuperview()
            
            blurEmojiView?.alpha = 0
        } completion: { [weak self] _ in
            guard let self = self else { return }
            highlightEmojiCell?.alpha = 1
            blurEmojiView?.removeFromSuperview()
            focusedEmojiView?.removeFromSuperview()
            
            highlightEmojiCell = nil
            blurEmojiView = nil
            focusedEmojiView = nil
            reactionHostViewController = nil
            menuHostViewController = nil
        }
    }
    
    /// Attach Emoji And Menu Action
    private func attachEmojiAndMenu(
        to message: MessageItem,
        in uiWindow: UIWindow
    ) {
        guard let focusedEmojiView else { return }
                
        /// Reaction Picker Menu View Model
        let reactionPickerMenuViewModel = ReactionPickerMenuViewModel(
            message: message,
            channel: viewModel.channel
        )
        
        // MARK: Reaction Picker View
        let reactionPickerView = ReactionPickerView(
            reactionPickerMenuViewModel: reactionPickerMenuViewModel,
            message: message
        ) { action in
            switch action {
            case .reaction:
                self.dismissContext()
            }
        }
        
        reactionHostViewController = UIHostingController(rootView: reactionPickerView)
        reactionHostViewController?.view.backgroundColor = .clear
        reactionHostViewController?.view.translatesAutoresizingMaskIntoConstraints = false
        
        guard let reactionHostViewController else { return }
        
        
        
        uiWindow.addSubview(reactionHostViewController.view)
        
        /// Set Constraint
        reactionHostViewController.view.bottomAnchor.constraint(equalTo: focusedEmojiView.topAnchor).isActive = true
        reactionHostViewController.view.leadingAnchor.constraint(equalTo: focusedEmojiView.leadingAnchor, constant: 20).isActive = message.direction == .received
        reactionHostViewController.view.trailingAnchor.constraint(equalTo: focusedEmojiView.trailingAnchor, constant: -20).isActive = message.direction == .sent
        
        self.reactionHostViewController = reactionHostViewController
        
        // MARK: Menu Picker View
        let menuPickerView = MenuPickerView(
            message: message,
            reactionPickerMenuViewModel: reactionPickerMenuViewModel
        ) { action in
            
            self.viewModel.messageInteractBlurCurrent = message
            
            switch action {
            case .reply:
                self.viewModel.isOpenReplyBox = true
                self.viewModel.isFocusTextFieldChat = true
            case .unsend:
                self.viewModel.isShowBoxChoiceUnsent = true
            case .forward:
                self.viewModel.isShowForwardSheet = true
            default:
                break
            }
            
            self.dismissContext()
            
        }
        menuHostViewController = UIHostingController(rootView: menuPickerView)
        menuHostViewController?.view.backgroundColor = .clear
        menuHostViewController?.view.translatesAutoresizingMaskIntoConstraints = false
        
        guard let menuHostViewController else { return }
        
        uiWindow.addSubview(menuHostViewController.view)
        
        /// Set constraint
        menuHostViewController.view.topAnchor.constraint(equalTo: focusedEmojiView.bottomAnchor).isActive = true
        menuHostViewController.view.leadingAnchor.constraint(equalTo: focusedEmojiView.leadingAnchor, constant: 20).isActive = message.direction == .received
        menuHostViewController.view.trailingAnchor.constraint(equalTo: focusedEmojiView.trailingAnchor, constant: -20).isActive = message.direction == .sent
        
        self.menuHostViewController = menuHostViewController
    }
}


/// Manage List Message
extension MessageListController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.messages.count
    }
    
    /// Create cell
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        
        cell.backgroundColor = .clear
        
        /// message
        let message = viewModel.messages[indexPath.item]
        /// is new day
        let isNewDay = viewModel.isNewDay(for: message, at: indexPath.item)
        /// is show sender
        let isShowNameSender = viewModel.showSenderName(for: message, at: indexPath.item)
        /// is show avatar
        let isShowAvatarSender = viewModel.showSenderAvatar(for: message, at: indexPath.item)
        
        cell.contentConfiguration = UIHostingConfiguration(content: {
            BubbleView(
                message: message,
                channel: viewModel.channel,
                isNewDay: isNewDay,
                isShowNameSender: isShowNameSender,
                isShowAvatarSender: isShowAvatarSender,
                isShowUsersSeen: true,
                viewModel: viewModel
            ) { state, message in
                self.viewModel.isShowReactions = state
                self.viewModel.messageReactions = message
            }
        })
        
        return cell
    }
    
    /// Did selection item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        /// Get message in that index
        let messageItem = viewModel.messages[indexPath.item]
        
        /// Selected messaged
        viewModel.bubbleMessageDidSelect = messageItem
        
        if viewModel.bubbleMessageDidSelect?.messageReply == nil {
            return
        }
        
        self.messageCollectionView.scrollToMessageDidSelected(at: .centeredVertically, viewModel: viewModel, animate: true)
        
        switch messageItem.type {
        case .photo:
            displayPreviewImage(message: messageItem, indexPath)
        case .video:
            displayPreviewVideo(message: messageItem, indexPath)
        case .fileMedia:
            if let nameOfFile = messageItem.nameOfFile {
                readContentsOfFile(fileName: nameOfFile)
            }
        default:
            break
        }
    }
    
    /// Read the file of FileMedia Type
    private func readContentsOfFile(fileName: String) {
        viewModel.readContentOfsFile(fileName)
    }
    
    /// Display Preview Image message
    private func displayPreviewImage(message: MessageItem, _ indexPath: IndexPath) {
        
        /// Selected cell
        guard let selectedCell = messageCollectionView.cellForItem(at: indexPath) else { return }
        blurViewModel.startingFrame = selectedCell.superview?.convert(selectedCell.frame, to: nil)
        
        /// Capture snapshot view
        guard let snapshotCell = selectedCell.snapshotView(afterScreenUpdates: false) else { return }
        
        blurViewModel.focusedView = UIView(frame: blurViewModel.startingFrame ?? .zero)
        guard let focusedView = blurViewModel.focusedView else { return }
        focusedView.isUserInteractionEnabled = false
        
        /// Create Blur View
        let blurEffect = UIBlurEffect(style: .regular)
        blurViewModel.blurView = UIVisualEffectView(effect: blurEffect)
        guard let blurView = blurViewModel.blurView else { return }
        blurView.contentView.isUserInteractionEnabled = true
        blurView.alpha = 0
        
        /// Get ui window
        guard let keyWindow = UIWindowScene.current?.keyWindow else { return }
        keyWindow.addSubview(blurView)
        keyWindow.addSubview(focusedView)
        focusedView.addSubview(snapshotCell)
        
        /// Set frame for blur view
        blurView.frame = keyWindow.frame
        
        let blurOverView = BlurView(message: message) { action in
            self.blurViewModel.blurViewAction(action)
        } // SwiftUI
        
        /// Highlight cell
        blurViewModel.highlightCell = selectedCell
        blurViewModel.highlightCell?.alpha = 0
        
        
        let hostingController = UIHostingController(rootView: blurOverView)
        /// Set background for hosting controller is clear
        hostingController.view.backgroundColor = .clear
        /// Add hosting controller contain the swiftui into the blurview
        blurView.contentView.addSubview(hostingController.view)
        
        /// Set contraints for this hosting controller
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: blurView.contentView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor)
        ])
        
        let shrinkCell = shrinkCell(blurViewModel.startingFrame?.height ?? 0)
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn) {
            /// Set blur view is visible
            blurView.alpha = 1
            
            focusedView.center.y = keyWindow.center.y
            
//            if message.isNotMe {
//                focusedView.center.x = keyWindow.center.x + 95
//            } else {
//                focusedView.center.x = keyWindow.center.x - 95
//            }

            snapshotCell.frame = focusedView.bounds
            
            /// Scale
            if shrinkCell {
                focusedView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }
        }
    }
    
    /// Display Preview Video message
    private func displayPreviewVideo(message: MessageItem, _ indexPath: IndexPath) {
        
        /// Selected cell
        guard let selectedCell = messageCollectionView.cellForItem(at: indexPath) else { return }
        blurViewModel.startingFrame = selectedCell.superview?.convert(selectedCell.frame, to: nil)
        
        /// Capture snapshot view
        guard let snapshotCell = selectedCell.snapshotView(afterScreenUpdates: false) else { return }
        
        blurViewModel.focusedView = UIView(frame: blurViewModel.startingFrame ?? .zero)
        guard let focusedView = blurViewModel.focusedView else { return }
        focusedView.isUserInteractionEnabled = false
        
        /// Create Blur View
        let blurEffect = UIBlurEffect(style: .regular)
        blurViewModel.blurView = UIVisualEffectView(effect: blurEffect)
        guard let blurView = blurViewModel.blurView else { return }
        blurView.contentView.isUserInteractionEnabled = true
        blurView.alpha = 0
        
        /// Get ui window
        guard let keyWindow = UIWindowScene.current?.keyWindow else { return }
        keyWindow.addSubview(blurView)
        keyWindow.addSubview(focusedView)
        focusedView.addSubview(snapshotCell)
        
        /// Set frame for blur view
        blurView.frame = keyWindow.frame
        
        let blurOverView = BlurView(message: message) { action in
            self.blurViewModel.blurViewAction(action)
        } // SwiftUI
        
        let hostingController = UIHostingController(rootView: blurOverView)
        /// Set background for hosting controller is clear
        hostingController.view.backgroundColor = .clear
        /// Add hosting controller contain the swiftui into the blurview
        blurView.contentView.addSubview(hostingController.view)
        
        let shrinkCell = shrinkCell(blurViewModel.startingFrame?.height ?? 0)
        
        /// Set contraints for this hosting controller
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: blurView.contentView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor)
        ])
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn) {
            /// Set blur view is visible
            blurView.alpha = 1
            
            focusedView.center.y = keyWindow.center.y
            
//            if message.isNotMe {
//                focusedView.center.x = keyWindow.center.x + 60
//            } else {
//                focusedView.center.x = keyWindow.center.x - 60
//            }

            snapshotCell.frame = focusedView.bounds
            
            /// Scale
            if shrinkCell {
                focusedView.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            }
            
            /// Difference
            focusedView.alpha = 0
        }
    }
    
    /// Checking the height cell view wheather larger 2/3 screen -> scale it
    private func shrinkCell(_ cellHeight: CGFloat) -> Bool {
        let screenHeight = (UIWindowScene.current?.screenHeight ?? 0) / 0.5
        let spacingForMenuView = screenHeight - cellHeight
        return spacingForMenuView < 190
    }
    
    /// Action checking to display button scroll to bottom
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let contentOffsetY = scrollView.contentOffset.y
            let screenHeight = view.frame.height
            
            if contentOffsetY > screenHeight {
                buttonScrollToBottom.isHidden = true
                buttonScrollToBottom.isEnabled = false
            } else {
                if viewModel.messages.count > 10 {
                    buttonScrollToBottom.isHidden = false
                    buttonScrollToBottom.isEnabled = true
                }
            }
        }
}

/// Scroll Action
extension UICollectionView {
    func scrollToLastItem(at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        /// Check number of message wheather larger 1 message
        guard numberOfItems(inSection: numberOfSections - 1) > 0 else { return }
        
        let lastSectionIndex = numberOfSections - 1
        let lastRowIndex = numberOfItems(inSection: lastSectionIndex) - 1
        let lastRowIndexPath = IndexPath(row: lastRowIndex, section: lastSectionIndex)
        scrollToItem(at: lastRowIndexPath, at: scrollPosition, animated: animated)
    }
    
    func scrollToMessageDidSelected(at scrollPosition: UICollectionView.ScrollPosition, viewModel: ChatRoomScreenViewModel, animate: Bool) {
        
        viewModel.findBubbleMessageScrollTo { indexMessage in
            if let indexMessage {
                let messageRowIndexPath = IndexPath(item: indexMessage, section: 0)
                self.scrollToItem(at: messageRowIndexPath, at: scrollPosition, animated: animate)
            }
        }
    }
}

extension MessageListController {
    enum BlurMessageViewAction {
        case closeBlurViewImage
        case closeBlurViewVideo
    }
}

#Preview {
    MessageListView(ChatRoomScreenViewModel(channel: .placeholder))
        .ignoresSafeArea()
}
