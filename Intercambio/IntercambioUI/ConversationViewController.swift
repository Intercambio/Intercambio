//
//  ConversationViewController.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 21.10.16.
//  Copyright © 2016, 2017 Tobias Kräntzer.
//
//  This file is part of Intercambio.
//
//  Intercambio is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option)
//  any later version.
//
//  Intercambio is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
//  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along with
//  Intercambio. If not, see <http://www.gnu.org/licenses/>.
//
//  Linking this library statically or dynamically with other modules is making
//  a combined work based on this library. Thus, the terms and conditions of the
//  GNU General Public License cover the whole combination.
//
//  As a special exception, the copyright holders of this library give you
//  permission to link this library with independent modules to produce an
//  executable, regardless of the license terms of these independent modules,
//  and to copy and distribute the resulting executable under terms of your
//  choice, provided that you also meet, for each linked independent module, the
//  terms and conditions of the license of that module. An independent module is
//  a module which is not derived from or based on this library. If you modify
//  this library, you must extend this exception to your version of the library.
//


import UIKit
import Fountain

public class ConversationViewController: UICollectionViewController, ConversationView, UICollectionViewDelegateConversationViewLayout, UICollectionViewDelegateAction {

    class CollectionView : UICollectionView {
        // Override to fix a missbehaviour that appears when the
        // compose cell becomes the first responde and the keyboard appears.
        override func scrollToItem(at indexPath: IndexPath, at scrollPosition: UICollectionViewScrollPosition, animated: Bool) {
            super.scrollToItem(at: indexPath, at: .bottom, animated: animated)
        }
    }
    
    var presenter: ConversationViewEventHandler?
    var dataSource: FTDataSource? {
        didSet {
            collectionViewAdapter?.dataSource = dataSource
            shouldScrollToBottom = true
        }
    }
    
    var isContactPickerVisible: Bool = false {
        didSet {
            if let view = contactPickerViewController?.viewIfLoaded {
                view.isHidden = !isContactPickerVisible
            }
        }
    }
    
    var contactPickerViewController: UIViewController? {
        willSet {
            if let viewController = contactPickerViewController {
                viewController.view.removeFromSuperview()
                viewController.removeFromParentViewController()
            }
        }
        didSet {
            if let viewController = contactPickerViewController {
                if isViewLoaded {
                    addChildViewController(viewController)
                }
            }
        }
    }
    
    private var dummyTextView: UITextView?
    private var collectionViewAdapter: FTCollectionViewAdapter?
    private var shouldScrollToBottom: Bool = false
    
    public init() {
        let layout = ConversationViewLayout()
        super.init(collectionViewLayout: layout)
        self.hidesBottomBarWhenPushed = true
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        dummyTextView = UITextView()
        
        if let collectionView = self.collectionView,
           let dummyTextView = self.dummyTextView {
            self.collectionView = CollectionView(frame: collectionView.frame,
                                                 collectionViewLayout: collectionView.collectionViewLayout)
            view.insertSubview(dummyTextView, belowSubview: collectionView)
        }
        
        collectionView?.allowsSelection = false
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        collectionView?.alwaysBounceVertical = true
        
        collectionViewAdapter = FTCollectionViewAdapter(collectionView: collectionView)
        
        collectionView?.register(ConversationViewAvatarView.classForCoder(),
                                 forSupplementaryViewOfKind: ConversationViewLayoutElementKindAvatar,
                                 withReuseIdentifier: ConversationViewLayoutElementKindAvatar)
        collectionViewAdapter?.forSupplementaryViews(ofKind: ConversationViewLayoutElementKindAvatar,
                                                     matching: nil,
                                                     useViewWithReuseIdentifier: ConversationViewLayoutElementKindAvatar) {
                                                        (view, item, indexPath, dataSource) in
                                                        if let avatar = view as? ConversationViewAvatarView,
                                                            let viewModel = item as? ConversationViewModel{
                                                            avatar.viewModel = viewModel
                                                        }
        }

        collectionView?.register(ConversationViewComposeCell.classForCoder(), forCellWithReuseIdentifier: "compose")
        collectionViewAdapter?.forItemsMatching(NSPredicate(format: "editable == YES"), useCellWithReuseIdentifier: "compose") {
            (view, item, indexPath, dataSource) in
            if  let cell = view as? ConversationViewComposeCell,
                let viewModel = item as? ConversationViewModel {
                cell.viewModel = viewModel
            }
        }
        
        collectionView?.register(ConversationViewMessageCell.classForCoder(), forCellWithReuseIdentifier: "message")
        collectionViewAdapter?.forItemsMatching(nil, useCellWithReuseIdentifier: "message") {
            (view, item, indexPath, dataSource) in
            if  let cell = view as? ConversationViewMessageCell,
                let viewModel = item as? ConversationViewModel {
                cell.viewModel = viewModel
            }
        }
        
        collectionView?.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "undefined")
        collectionViewAdapter?.forItemsMatching(nil, useCellWithReuseIdentifier: "undefined") {
            (view, item, indexPath, dataSource) in
            if  let cell = view as? UICollectionViewCell {
                cell.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
            }
        }
        
        collectionViewAdapter?.delegate = self
        collectionViewAdapter?.dataSource = dataSource
        
        if let viewController = contactPickerViewController {
            addChildViewController(viewController)
            view.addSubview(viewController.view)
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                               options: [],
                                                               metrics: [:],
                                                               views: ["view":viewController.view]))

            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                               options: [],
                                                               metrics: [:],
                                                               views: ["view": viewController.view,
                                                                       "top": topLayoutGuide,
                                                                       "bottom": bottomLayoutGuide]))
            viewController.view.isHidden = !isContactPickerVisible
        }
        
        shouldScrollToBottom = true
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if shouldScrollToBottom {
            scrollToBottom(animated: false)
            shouldScrollToBottom = false
        }
        
        var insets = collectionView?.contentInset ?? UIEdgeInsets()
        insets.top = topLayoutGuide.length
        if isContactPickerVisible {
            if let viewController = contactPickerViewController as? ContentView, let contentView = viewController.contentView {
                let rect = view.convert(contentView.bounds, from: contentView)
                insets.top = rect.maxY
            }
        }
        collectionView?.scrollIndicatorInsets = insets
        collectionView?.contentInset = insets
    }
    
    // Actions
    
    func scrollToBottom() {
        scrollToBottom(animated: true)
    }
    
    func scrollToBottom(animated: Bool) {
        if let collectionView = self.collectionView {
            var contentOffset = CGPoint()
            let collectionViewRect = UIEdgeInsetsInsetRect(collectionView.bounds, collectionView.contentInset)
            if collectionView.contentSize.height > collectionViewRect.height {
                contentOffset.y = collectionView.contentSize.height - (collectionView.bounds.height - collectionView.contentInset.bottom)
            } else {
                contentOffset.y = -1 * collectionView.contentInset.top
            }
            collectionView.setContentOffset(contentOffset, animated: animated)
        }
    }
    
    // MARK: UICollectionViewDelegateConversationViewLayout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath,
                        maxWidth: CGFloat,
                        layoutMargins: UIEdgeInsets) -> CGSize{
        return preferredSize(forItemAt: indexPath, maxWidth: maxWidth, layoutMargins: layoutMargins)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        layoutItemOfItemAt indexPath: IndexPath) -> ConversationViewLayoutItem {

        var direction = ConversationViewLayoutDirection.undefined
        var origin = NSUUID().uuidString
        var temporary = false
        var type: ConversationViewModelType = .normal
        
        if let model = dataSource?.item(at: indexPath) as? ConversationViewModel {
            switch model.direction {
            case .undefined:
                direction = .undefined
            case .inbound:
                direction = .inbound
            case .outbound:
                direction = .outbound
            }
            
            if let url = model.origin {
                origin = url.absoluteString
            }
            
            temporary = model.temporary
            type = model.type
        }
        return ConversationViewLayoutItem(direction: direction, type: type, origin: origin, temporary: temporary)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        timestampOfItemAt indexPath: IndexPath) -> Date? {
        if let model = dataSource?.item(at: indexPath) as? ConversationViewModel {
            return model.timestamp
        } else {
            return nil
        }
    }
    
    // MARK: UICollectionViewDelegate
    
    public override func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if (dummyTextView?.isFirstResponder ?? false) {
            if let model = dataSource?.item(at: indexPath) as? ConversationViewModel {
                if model.editable == true {
                    cell.becomeFirstResponder()
                }
            }
        }
    }
    
    public override func collectionView(_ collectionView: UICollectionView,
                                 didEndDisplaying cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath) {
        cell.resignFirstResponder()
    }
    
    public override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return presenter?.shouldShowMenu(for: indexPath) ?? false
    }
    
    public override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath?, withSender sender: Any?) -> Bool {
        if action == #selector(collectionView(_:handle:forItemAt:sender:)) {
            return true
        } else if let path = indexPath {
            return presenter?.canPerformAction(action, forItemAt: path) ?? false
        } else {
            return false
        }
    }
    
    public override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        if let responder = sender as? UIResponder {
            if responder.isFirstResponder {
                dummyTextView?.becomeFirstResponder()
            }
        }
        self.presenter?.performAction(action, forItemAt: indexPath)
    }
    
    // MARK: UICollectionViewDelegateAction
    
    public func collectionView(_ collectionView: UICollectionView, handle controlEvents: UIControlEvents, forItemAt indexPath: IndexPath, sender: Any?) {
        if let textView = sender as? UITextView {
            if controlEvents.contains(.editingChanged) {
                collectionViewAdapter?.performUserDrivenChange({ 
                    self.presenter?.setValue(textView.attributedText, forItemAt: indexPath)
                    self.invalidateLayout(ofItemAt: indexPath)
                })
            }
        }
    }
    
    // MARK: Layout
    
    private func invalidateLayout(ofItemAt indexPath: IndexPath) {
        if let attributes = self.collectionView?.layoutAttributesForItem(at: indexPath) as? ConversationViewLayoutAttributes {
            
            let currentSize = attributes.size
            let size = preferredSize(forItemAt: indexPath,
                                     maxWidth: attributes.maxWidth ?? CGFloat(0),
                                     layoutMargins: attributes.layoutMargins ?? UIEdgeInsets())
            
            if !size.equalTo(currentSize) {
                let context = ConversationViewLayoutInvalidationContext()
                context.invalidateItems(at: [indexPath])
                
                let heightAdjustment = size.height - currentSize.height;
                if (heightAdjustment != 0) {
                    context.contentSizeAdjustment = CGSize(width: 0, height: heightAdjustment);
                    context.contentOffsetAdjustment = CGPoint(x: 0, y: heightAdjustment);
                }
                
                collectionViewLayout.invalidateLayout(with: context)
            }
        }
    }
    
    private func preferredSize(forItemAt indexPath: IndexPath,
                               maxWidth: CGFloat,
                               layoutMargins: UIEdgeInsets) -> CGSize {
        if let model = dataSource?.item(at: indexPath) as? ConversationViewModel {
            if model.editable == true {
                return ConversationViewComposeCell.preferredSize(for: model,
                                                                 width: maxWidth,
                                                                 layoutMargins: layoutMargins)
            } else {
                return ConversationViewMessageCell.preferredSize(for: model,
                                                                 width: maxWidth,
                                                                 layoutMargins: layoutMargins)
            }
        } else {
            return CGSize()
        }
    }
}
