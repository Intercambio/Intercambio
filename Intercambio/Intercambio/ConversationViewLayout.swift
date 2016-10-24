//
//  ConversationViewLayout.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 24.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

let ConversationViewLayoutElementKindAvatar = "ConversationViewLayoutElementKindAvatar"
let ConversationViewLayoutTimestampDecorationKind = "ConversationViewLayoutTimestampDecorationKind"

enum ConversationViewLayoutDirection {
    case undefined
    case inbound
    case outbound
}

@objc class ConversationViewLayoutItem : NSObject {
    
    init(direction: ConversationViewLayoutDirection, origin: String, temporary: Bool) {
        self.direction = direction
        self.origin = origin
        self.temporary = temporary
    }
    
    var direction: ConversationViewLayoutDirection
    var origin: String
    var temporary: Bool
}

@objc protocol UICollectionViewDelegateConversationViewLayout: UICollectionViewDelegate {
    @objc func collectionView(_ collectionView: UICollectionView,
                              layout collectionViewLayout: UICollectionViewLayout,
                              sizeForItemAt indexPath: IndexPath,
                              maxWidth: CGFloat,
                              layoutMargins: UIEdgeInsets) -> CGSize
    
    @objc func collectionView(_ collectionView: UICollectionView,
                              layout collectionViewLayout: UICollectionViewLayout,
                              layoutItemOfItemAt indexPath: IndexPath) -> ConversationViewLayoutItem
    
    @objc func collectionView(_ collectionView: UICollectionView,
                              layout collectionViewLayout: UICollectionViewLayout,
                              timestampOfItemAt indexPath: IndexPath) -> Date
}

class ConversationViewLayout: UICollectionViewLayout {
    
    private var dataSourceCountsAreValid: Bool
    private var layoutMetricsAreValid: Bool
    
    private var invalidated: [NSIndexPath]
    
    private var mainFragment: ConversationViewLayoutFragment?
    private var previourMainFragment: ConversationViewLayoutFragment?
    
    override init() {
        dataSourceCountsAreValid = false
        layoutMetricsAreValid = false
        invalidated = []
        super.init()
        
        register(ConversationViewGroupHeaderView.classForCoder(), forDecorationViewOfKind: ConversationViewLayoutTimestampDecorationKind)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        
        previourMainFragment = mainFragment
        
        if dataSourceCountsAreValid == false {
            mainFragment = generateMainFragment()
            layoutMetricsAreValid = false
            dataSourceCountsAreValid = true
        }
        
        if (layoutMetricsAreValid == false || invalidated.count > 0) {
        
            let lineHeight = UIFont.preferredFont(forTextStyle: .body).lineHeight
            let offset = CGPoint(x: 0, y: 0)
            let width = collectionView != nil ? (collectionView?.bounds.width)! : 0
            
            mainFragment?.layout(offset: offset, width: width, position: [.first, .last]) {
                (indexPath, width, layoutMargins) in
                return CGSize(width: width, height: lineHeight)
            }
            
            layoutMetricsAreValid = true
        }
        
        super.prepare()
    }
    
    override var collectionViewContentSize: CGSize {
        if let fragment = mainFragment {
            return fragment.rect.size
        } else {
            return CGSize()
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return mainFragment?.layoutAttributesForElements(in: rect)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return mainFragment?.layoutAttributesForItem(at: indexPath)
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return mainFragment?.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
    }
    
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return mainFragment?.layoutAttributesForDecorationView(ofKind: elementKind, at: indexPath)
    }
    
    // Generate Fragments
    
    private func generateMainFragment() -> ConversationViewLayoutFragment {
        
        let conversation = ConversationViewLayoutConversationFragment()
        conversation.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        var previousTimestamp : Date? = nil
        var previousLayoutItem: ConversationViewLayoutItem? = nil
        
        enumerateItems { (layoutItem, timestamp, indexPath) in
            
            let showAvatar = (layoutItem.direction == .inbound)
            
            if previousTimestamp == nil || fabs(previousTimestamp!.timeIntervalSince(timestamp)) > 60 * 15 {
                // Start a new chapter if the gap between the messages exceeded a certain threshold
                conversation.addChapter(timestamp: timestamp, showAvatar: showAvatar)
            } else if previousLayoutItem == nil || previousLayoutItem!.origin != layoutItem.origin {
                // Start a new paragraph if the origin of the message did change
                conversation.addParagraph(showAvatar: showAvatar)
            }
            
            var alignment: ConversationViewLayoutFragmentAlignment
            switch (layoutItem.direction) {
            case .undefined:
                alignment = .center
            case .inbound:
                alignment = .leading
            case .outbound:
                alignment = .trailing
            }
            
            conversation.addMessage(at: indexPath, alignment: alignment)
            previousTimestamp = timestamp
            previousLayoutItem = layoutItem
        }
        
        return conversation
    }
    
    // Enumerate Items
    
    private func enumerateItems(_ block: (ConversationViewLayoutItem, Date, IndexPath) -> Void) {
        
        if let collectionView = self.collectionView {
            
            let numberOfSections = collectionView.numberOfSections
            for section in 0 ..< numberOfSections {
            
                let numberOfItems = collectionView.numberOfItems(inSection: section)
                for item in 0 ..< numberOfItems {
                    
                    let indexPath = IndexPath(item: item, section: section)
                    let item = layoutItem(at: indexPath)
                    let date = timestamp(at: indexPath)
                    
                    block(item, date, indexPath)
                }
            }
        }
    }
    
    private func layoutItem(at indexPath: IndexPath) -> ConversationViewLayoutItem {
        if let collectionView = self.collectionView, let delegate = collectionView.delegate as? UICollectionViewDelegateConversationViewLayout {
            return delegate.collectionView(collectionView, layout: self, layoutItemOfItemAt: indexPath)
        } else {
            return ConversationViewLayoutItem(direction: .undefined, origin: NSUUID().uuidString, temporary: false)
        }
    }
    
    private func timestamp(at indexPath: IndexPath) -> Date {
        if let collectionView = self.collectionView, let delegate = collectionView.delegate as? UICollectionViewDelegateConversationViewLayout {
            return delegate.collectionView(collectionView, layout: self, timestampOfItemAt: indexPath)
        } else {
            return Date.distantFuture
        }
    }
}
