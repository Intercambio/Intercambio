//
//  ConversationViewLayoutMessageFragment.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 24.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

class ConversationViewLayoutMessageFragment: ConversationViewLayoutAbstractFragment {

    let indexPath: IndexPath
    let alignment: ConversationViewLayoutFragmentAlignment

    init(indexPath: IndexPath, alignment: ConversationViewLayoutFragmentAlignment) {
        self.indexPath = indexPath
        self.alignment = alignment
        maxWidth = 0
        super.init()
    }

    // Index Paths
    
    override var firstIndexPath: IndexPath? { return indexPath }
    override var lastIndexPath: IndexPath? { return indexPath }
    
    // Generate Layout
    
    var maxWidth: CGFloat
    
    override func layout(offset: CGPoint,
                width: CGFloat,
                position: ConversationViewLayoutFragmentPosition,
                sizeCallback: (IndexPath, CGFloat, UIEdgeInsets) -> CGSize) {
        
        let minPadding = CGFloat(56.0)
        let maxReadableWidth = CGFloat(480)
        let layoutMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        
        // Size
        
        maxWidth = fmin(maxReadableWidth, width - minPadding)
        
        var size = sizeCallback(indexPath, maxWidth, layoutMargins)
        size.width = fmin(size.width, width)
        
        rect.size = size
        
        // Offset
        
        switch alignment {
        case .leading:
            rect.origin = offset
            
        case .trailing:
            rect.origin = CGPoint(x: offset.x + (width - size.width), y: offset.y)
            
        case .center:
            rect.origin = CGPoint(x: offset.x + 0.5 * (width - size.width), y: offset.y)
        }
    
        // Attributes
        
        let attributes = ConversationViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = rect
        attributes.alignment = alignment
        attributes.position = position
        attributes.maxWidth = maxWidth
        attributes.layoutMargins = layoutMargins
        layoutAttributes = attributes
    }
    
    // Layout Attributes
    
    var layoutAttributes: UICollectionViewLayoutAttributes?
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes] {
        if let attributes = layoutAttributes {
            if rect.intersects(attributes.frame) {
                return [attributes]
            } else {
                return []
            }
        } else {
            return []
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if let attributes = layoutAttributes {
            if self.indexPath == indexPath  {
                return attributes
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
