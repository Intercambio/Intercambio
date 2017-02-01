//
//  ConversationViewLayoutParagraphFragment.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 24.10.16.
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

class ConversationViewLayoutParagraphFragment: ConversationViewLayoutAbstractFragment {
    
    let showAvatar: Bool
    
    init(showAvatar: Bool) {
        self.showAvatar = showAvatar
        super.init()
    }
    
    // Generate Layout
    
    var alignment: ConversationViewLayoutFragmentAlignment {
        if let fragment = childFragments.first as? ConversationViewLayoutMessageFragment {
            return fragment.alignment
        } else {
            return .center
        }
    }
    
    override func layout(
        offset: CGPoint,
        width: CGFloat,
        position: ConversationViewLayoutFragmentPosition,
        options: [String: Any],
        sizeCallback: (IndexPath, CGFloat, UIEdgeInsets) -> CGSize
    ) {
        
        let avatarPadding = options["avatar_padding"] as? CGFloat ?? CGFloat(4)
        let avatarSize = options["avatar_size"] as? CGSize ?? CGSize(width: 28, height: 28)
        
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
                break
            }
            
            super.layout(
                offset: newOffset,
                width: newWidth,
                position: position,
                options: options,
                sizeCallback: sizeCallback
            )
            
            if let fragment = childFragments.last {
                
                var frame: CGRect?
                
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
            
            super.layout(
                offset: offset,
                width: width,
                position: position,
                options: options,
                sizeCallback: sizeCallback
            )
            
            layoutAttributes = nil
        }
    }
    
    override func fragmentSpacing(_ options: [String: Any]) -> CGFloat {
        if let spacing = options["message_spacing"] as? CGFloat {
            return spacing
        } else {
            return 0
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
    
    override func indexPathsOfSupplementaryView(ofKind elementKind: String) -> [IndexPath] {
        var result: [IndexPath] = []
        for fragment in childFragments {
            result.append(contentsOf: fragment.indexPathsOfSupplementaryView(ofKind: elementKind))
        }
        if let attributes = layoutAttributes {
            if elementKind == attributes.representedElementKind {
                result.append(attributes.indexPath)
            }
        }
        return result
    }
}
