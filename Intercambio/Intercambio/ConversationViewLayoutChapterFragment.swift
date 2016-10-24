//
//  ConversationViewLayoutChapterFragment.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 24.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

class ConversationViewLayoutChapterFragment: ConversationViewLayoutAbstractFragment {
    
    let timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
        super.init()
        self.fragmentSpacing = 5
    }

    // Generate Layout
    
    override func layout(offset: CGPoint,
                         width: CGFloat,
                         position: ConversationViewLayoutFragmentPosition,
                         sizeCallback: (IndexPath, CGFloat, UIEdgeInsets) -> CGSize) {
        
        let headerHeight: CGFloat = 34.0
        
        super.layout(offset: CGPoint(x: offset.x, y: offset.y + headerHeight),
                     width: width,
                     position: position,
                     sizeCallback: sizeCallback)
        
        rect.origin = offset
        rect.size.height = rect.size.height + headerHeight
        
        if let indexPath = firstIndexPath {
            let attributes = ConversationViewLayoutAttributes(forDecorationViewOfKind: ConversationViewLayoutTimestampDecorationKind, with: indexPath)
            attributes.frame = CGRect(x: offset.x, y: offset.y, width: width, height: headerHeight)
            attributes.zIndex = 1
            attributes.timestamp = timestamp
            layoutAttributes = attributes
        } else {
            layoutAttributes = nil
        }
    }
    
    // Layout Attributes
    
    var layoutAttributes: UICollectionViewLayoutAttributes?
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes] {
        var result = super.layoutAttributesForElements(in: rect)
        if let attributes = layoutAttributes {
            if rect.intersects(attributes.frame) {
                result.append(attributes)
            }
        }
        return result
    }
    
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if let attributes = layoutAttributes {
            if attributes.indexPath == indexPath && attributes.representedElementKind == elementKind {
                return attributes
            }
        }
        return super.layoutAttributesForDecorationView(ofKind: elementKind, at: indexPath)
    }
}
