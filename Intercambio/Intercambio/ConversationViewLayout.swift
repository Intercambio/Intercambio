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
    
    var paragraphSpacing: CGFloat = CGFloat(5)
    var messageSpacing: CGFloat = CGFloat(4)
    var contentInsets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    var headerHeight: CGFloat = CGFloat(34)
    var avatarSize: CGSize = CGSize(width: 38, height: 38)
    var avatarPadding: CGFloat = CGFloat(8)
    var maxReadableWidth: CGFloat = CGFloat(480)
    var minReadablePadding: CGFloat = CGFloat(48)
    var layoutMargins: UIEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    
    private var dataSourceCountsAreValid: Bool
    private var layoutMetricsAreValid: Bool
    
    private var invalidated: [IndexPath]
    
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
            
            mainFragment?.layout(offset: offset, width: width, position: [.first, .last], options: options()) {
                (indexPath, width, layoutMargins) in
                return CGSize(width: width, height: lineHeight)
            }
            
            layoutMetricsAreValid = true
        }
        
        super.prepare()
    }
    
    override func finalizeCollectionViewUpdates() {
        invalidated.removeAll()
        super.finalizeCollectionViewUpdates()
    }
    
    private func options() -> [String:Any] {
        var options: [String:Any] = [:]
        options["paragraph_spacing"] = paragraphSpacing
        options["message_spacing"] = messageSpacing
        options["content_insets"] = contentInsets
        options["header_height"] = headerHeight
        options["avatar_size"] = avatarSize
        options["avatar_padding"] = avatarPadding
        options["max_readable_width"] = maxReadableWidth
        options["min_readable_padding"] = minReadablePadding
        options["layout_margins"] = layoutMargins
        return options
    }
    
    // Content Size
    
    override var collectionViewContentSize: CGSize {
        if let fragment = mainFragment {
            return fragment.rect.size
        } else {
            return CGSize()
        }
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        var contentOffset = collectionView?.contentOffset ?? CGPoint()
        let offset = (mainFragment?.rect.height ?? CGFloat(0)) - (previourMainFragment?.rect.height ?? CGFloat(0))
        contentOffset.y = contentOffset.y + offset
        return contentOffset
    }
    
    // Generate Fragments
    
    private func generateMainFragment() -> ConversationViewLayoutFragment {
        
        let conversation = ConversationViewLayoutConversationFragment()
        
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
    
    // Invalidating the Layout
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if let collectionView = self.collectionView {
            return !collectionView.bounds.equalTo(newBounds)
        } else {
            return false
        }
    }
    
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        if let context = super.invalidationContext(forBoundsChange: newBounds) as? ConversationViewLayoutInvalidationContext {
            context.invalidateLayoutMetrics = true
            return context
        } else {
            return super.invalidationContext(forBoundsChange: newBounds)
        }
    }
    
    override func invalidateLayout(with ctx: UICollectionViewLayoutInvalidationContext) {
        if let context = ctx as? ConversationViewLayoutInvalidationContext {
            if context.invalidateEverything == true || context.invalidateDataSourceCounts {
                dataSourceCountsAreValid = false
            } else if context.invalidateLayoutMetrics {
                layoutMetricsAreValid = false
            } else if let invalidatedItemIndexPaths = context.invalidatedItemIndexPaths {
                for indexPath in invalidatedItemIndexPaths {
                    invalidated.append(indexPath)
                }
            }
        }
        super.invalidateLayout(with: ctx)
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
    
    // Layout Attributes
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return mainFragment?.layoutAttributesForElements(in: rect)
    }
    
    // Items
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return mainFragment?.layoutAttributesForItem(at: indexPath)
    }
    
    // Supplementary View
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return mainFragment?.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
    }
    
    override func initialLayoutAttributesForAppearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return mainFragment?.layoutAttributesForSupplementaryView(ofKind: elementKind, at: elementIndexPath)
    }
    
    override func indexPathsToInsertForSupplementaryView(ofKind elementKind: String) -> [IndexPath] {
        return mainFragment?.indexPathsOfSupplementaryView(ofKind: elementKind) ?? []
    }
    
    override func indexPathsToDeleteForSupplementaryView(ofKind elementKind: String) -> [IndexPath] {
        return previourMainFragment?.indexPathsOfSupplementaryView(ofKind: elementKind) ?? []
    }
    
    // Decoration View
    
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return mainFragment?.layoutAttributesForDecorationView(ofKind: elementKind, at: indexPath)
    }
    
    override func indexPathsToInsertForDecorationView(ofKind elementKind: String) -> [IndexPath] {
        return mainFragment?.indexPathsOfDecorationView(ofKind: elementKind) ?? []
    }

    override func indexPathsToDeleteForDecorationView(ofKind elementKind: String) -> [IndexPath] {
        return previourMainFragment?.indexPathsOfDecorationView(ofKind: elementKind) ?? []
    }
}
