//
//  ConversationViewLayoutParagraphFragment.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 24.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

class ConversationViewLayoutParagraphFragment: ConversationViewLayoutAbstractFragment {
    
    let showAvatar: Bool
    
    init(showAvatar: Bool) {
        self.showAvatar = showAvatar
        super.init()
        self.fragmentSpacing = 4
    }
    
    // Generate Layout
    
    var alignment: ConversationViewLayoutFragmentAlignment {
        if let fragment = childFragments.first as? ConversationViewLayoutMessageFragment {
            return fragment.alignment
        } else {
            return .center
        }
    }
    
    override func layout(offset: CGPoint,
                         width: CGFloat,
                         position: ConversationViewLayoutFragmentPosition,
                         sizeCallback: (IndexPath, CGFloat, UIEdgeInsets) -> CGSize) {

        let avatarPadding: CGFloat = 8
        let avatarSize = CGSize(width: 38, height: 38)
        
        if showAvatar {
            
            var newOffset = offset
            var newWidth = width
            
            switch alignment {
            case .leading:
                newOffset.x = newOffset.x + avatarSize.width + avatarPadding
                newWidth = newWidth - (avatarSize.width + avatarPadding)
                
            case .trailing:
                newWidth = newWidth - (avatarSize.width + avatarPadding)
            
            case .center:
                break;
            }
            
            super.layout(offset: newOffset,
                         width: newWidth,
                         position: position,
                         sizeCallback: sizeCallback)
            
            if let fragment = childFragments.last {
                
                var frame: CGRect? = nil
                
                switch alignment {
                case .leading:
                    var f = CGRect(origin: offset, size: avatarSize)
                    f.origin.y = fragment.rect.maxY - avatarSize.height
                    frame = f
                    
                case .trailing:
                    var f = CGRect(origin: offset, size: avatarSize)
                    f.origin.x = newOffset.x + newWidth + avatarPadding
                    f.origin.y = fragment.rect.maxY - avatarSize.height
                    frame = f
                    
                case .center:
                    break
                }
                
                if frame != nil {
                    let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: ConversationViewLayoutElementKindAvatar, with: firstIndexPath!)
                    attributes.frame = frame!
                    attributes.zIndex = 2
                    
                    layoutAttributes = attributes
                } else {
                    layoutAttributes = nil
                }
                
            } else {
                layoutAttributes = nil
            }
        } else {
            
            super.layout(offset: offset,
                         width: width,
                         position: position,
                         sizeCallback: sizeCallback)
            
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
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if let attributes = layoutAttributes {
            if attributes.indexPath == indexPath && attributes.representedElementKind == elementKind {
                return attributes
            }
        }
        return super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
    }
}
