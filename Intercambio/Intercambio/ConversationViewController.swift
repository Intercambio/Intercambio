//
//  ConversationViewController.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 21.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import Fountain

class ConversationViewController: UICollectionViewController, ConversationView, UICollectionViewDelegateConversationViewLayout, UICollectionViewDelegateAction {

    var eventHandler: ConversationViewEventHandler?
    var dataSource: FTDataSource? {
        didSet {
            collectionViewAdapter?.dataSource = dataSource
        }
    }
    
    init() {
        let layout = ConversationViewLayout()
        super.init(collectionViewLayout: layout)
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var collectionViewAdapter: FTCollectionViewAdapter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        collectionViewAdapter = FTCollectionViewAdapter(collectionView: collectionView)
        
        collectionView?.register(CoversationViewAvatarView.classForCoder(),
                                 forSupplementaryViewOfKind: ConversationViewLayoutElementKindAvatar,
                                 withReuseIdentifier: ConversationViewLayoutElementKindAvatar)
        collectionViewAdapter?.forSupplementaryViews(ofKind: ConversationViewLayoutElementKindAvatar,
                                                     matching: nil,
                                                     useViewWithReuseIdentifier: ConversationViewLayoutElementKindAvatar) {
                                                        (view, item, indexPath, dataSource) in
                                                        if let avatar = view as? CoversationViewAvatarView,
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
    }
    
    // View Model
    
    func viewModel(at indexPath: IndexPath) -> ConversationViewModel? {
        return dataSource?.item(at: indexPath) as? ConversationViewModel
    }
    
    // UICollectionViewDelegateConversationViewLayout
    
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
        
        if let model = viewModel(at: indexPath) {
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
        }
        return ConversationViewLayoutItem(direction: direction, origin: origin, temporary: temporary)
    }
    
    private func preferredSize(forItemAt indexPath: IndexPath,
                               maxWidth: CGFloat,
                               layoutMargins: UIEdgeInsets) -> CGSize {
        if let model = viewModel(at: indexPath) {
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
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        timestampOfItemAt indexPath: IndexPath) -> Date {
        if let model = viewModel(at: indexPath) {
            return model.timestamp
        } else {
            return Date.distantFuture
        }
    }
    
    // UICollectionViewDelegateAction
    
    func collectionView(_ collectionView: UICollectionView, handle controlEvents: UIControlEvents, forItemAt indexPath: IndexPath, sender: Any?) {
        if let textView = sender as? UITextView {
            if controlEvents.contains(.editingChanged) {
                collectionViewAdapter?.performUserDrivenChange({ 
                    self.eventHandler?.setValue(textView.attributedText, forItemAt: indexPath)
                    self.invalidateSize(forItemAt: indexPath)
                })
            }
        }
    }
    
    // Invalidate Layout
    
    private func invalidateSize(forItemAt indexPath: IndexPath) {
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
}
