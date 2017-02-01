//
//  ConversationViewLayoutMessageFragment.swift
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

class ConversationViewLayoutMessageFragment: ConversationViewLayoutAbstractFragment {
    
    let indexPath: IndexPath
    let alignment: ConversationViewLayoutFragmentAlignment
    
    init(indexPath: IndexPath, alignment: ConversationViewLayoutFragmentAlignment) {
        self.indexPath = indexPath
        self.alignment = alignment
        super.init()
    }
    
    // Index Paths
    
    override var firstIndexPath: IndexPath? { return indexPath }
    override var lastIndexPath: IndexPath? { return indexPath }
    
    // Generate Layout
    
    override func layout(
        offset: CGPoint,
        width: CGFloat,
        position: ConversationViewLayoutFragmentPosition,
        options: [String: Any],
        sizeCallback: (IndexPath, CGFloat, UIEdgeInsets) -> CGSize
    ) {
        
        let minPadding = options["min_readable_padding"] as? CGFloat ?? CGFloat(56.0)
        let maxReadableWidth = options["max_readable_width"] as? CGFloat ?? CGFloat(480)
        let layoutMargins = options["layout_margins"] as? UIEdgeInsets ?? UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        
        // Size
        
        let maxWidth = fmin(maxReadableWidth, width - minPadding)
        
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
            if self.indexPath == indexPath {
                return attributes
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
