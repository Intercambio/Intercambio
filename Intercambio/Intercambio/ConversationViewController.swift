//
//  ConversationViewController.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 21.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import Fountain

class ConversationViewController: UICollectionViewController, ConversationView, UICollectionViewDelegateConversationViewLayout {

    var eventHandler: ConversationViewEventHandler?
    var dataSource: FTDataSource? {
        didSet {
            collectionViewAdapter?.dataSource = dataSource
        }
    }
    
    init() {
        let layout = ConversationViewLayout()
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var collectionViewAdapter: FTCollectionViewAdapter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    // UICollectionViewDelegateConversationViewLayout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath,
                        maxWidth: CGFloat,
                        layoutMargins: UIEdgeInsets) -> CGSize{
        if let viewModel = dataSource?.item(at: indexPath) as? ConversationViewModel {
            return ConversationViewMessageCell.preferredSize(for: viewModel,
                                                             width: maxWidth,
                                                             layoutMargins: layoutMargins)
        } else {
            return CGSize()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        layoutItemOfItemAt indexPath: IndexPath) -> ConversationViewLayoutItem {

        var direction = ConversationViewLayoutDirection.undefined
        var origin = NSUUID().uuidString
        var temporary = false
        
        if let message = dataSource?.item(at: indexPath) as? ConversationViewModel {
            switch message.direction {
            case .undefined:
                direction = .undefined
            case .inbound:
                direction = .inbound
            case .outbound:
                direction = .outbound
            }
            
            if let url = message.origin {
                origin = url.absoluteString
            }
            
            temporary = message.temporary
        }
        return ConversationViewLayoutItem(direction: direction, origin: origin, temporary: temporary)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        timestampOfItemAt indexPath: IndexPath) -> Date {
        if let message = dataSource?.item(at: indexPath) as? ConversationViewModel {
            return message.timestamp
        } else {
            return Date.distantFuture
        }
    }
}
