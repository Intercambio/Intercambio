//
//  ConversationViewLayoutChapterFragment.swift
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

class ConversationViewLayoutChapterFragment: ConversationViewLayoutAbstractFragment {
    
    let timestamp: Date?
    
    init(timestamp: Date?) {
        self.timestamp = timestamp
        super.init()
    }

    // Generate Layout
    
    override func layout(offset: CGPoint,
                         width: CGFloat,
                         position: ConversationViewLayoutFragmentPosition,
                         options: [String:Any],
                         sizeCallback: (IndexPath, CGFloat, UIEdgeInsets) -> CGSize) {
        
        let headerHeight = options["header_height"] as? CGFloat ?? 0
        
        super.layout(offset: CGPoint(x: offset.x, y: offset.y + headerHeight),
                     width: width,
                     position: position,
                     options: options,
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
    
    override func fragmentSpacing(_ options: [String:Any]) -> CGFloat {
        if let spacing = options["paragraph_spacing"] as? CGFloat {
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
    
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if let attributes = layoutAttributes {
            if attributes.indexPath == indexPath && attributes.representedElementKind == elementKind {
                return attributes
            }
        }
        return super.layoutAttributesForDecorationView(ofKind: elementKind, at: indexPath)
    }
    
    override func indexPathsOfDecorationView(ofKind elementKind: String) -> [IndexPath] {
        var result: [IndexPath] = []
        for fragment in childFragments {
            result.append(contentsOf: fragment.indexPathsOfDecorationView(ofKind: elementKind))
        }
        if let attributes = layoutAttributes {
            if elementKind == attributes.representedElementKind {
                result.append(attributes.indexPath)
            }
        }
        return result
    }
}
