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
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var collectionViewAdapter: FTCollectionViewAdapter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        collectionViewAdapter = FTCollectionViewAdapter(collectionView: collectionView)
        collectionViewAdapter?.isEditing = true
        
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
        
        guard let dataSource = self.dataSource else {
            return nil
        }
        
        let numberOfItems = Int(dataSource.numberOfItems(inSection: UInt(indexPath.section)))
        if indexPath.item < numberOfItems {
            return dataSource.item(at: indexPath) as? ConversationViewModel
        } else {
            if let futureItemDataSource = dataSource as? FTFutureItemsDataSource {
                return futureItemDataSource.futureItem(at: IndexPath(item: indexPath.item - numberOfItems,
                                                                     section: indexPath.section)) as? ConversationViewModel
            } else {
                return nil
            }
        }
    }
    
    // UICollectionViewDelegateConversationViewLayout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath,
                        maxWidth: CGFloat,
                        layoutMargins: UIEdgeInsets) -> CGSize{
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
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        timestampOfItemAt indexPath: IndexPath) -> Date {
        if let model = viewModel(at: indexPath) {
            return model.timestamp
        } else {
            return Date.distantFuture
        }
    }
}
