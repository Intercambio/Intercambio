//
//  ConversationViewLayoutFragment.swift
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


struct ConversationViewLayoutFragmentPosition: OptionSet {
    let rawValue: Int
    
    static let first = ConversationViewLayoutFragmentPosition(rawValue: 1 << 1)
    static let last = ConversationViewLayoutFragmentPosition(rawValue: 1 << 2)
}

enum ConversationViewLayoutFragmentAlignment {
    case center
    case leading
    case trailing
}

protocol ConversationViewLayoutFragment : class {
    
    var childFragments: [ConversationViewLayoutFragment] { get }
    func append(_ fragment: ConversationViewLayoutFragment) -> Void
    
    var firstIndexPath: IndexPath? { get }
    var lastIndexPath: IndexPath? { get }
    
    var rect: CGRect { get }
    
    typealias SizeCallback = (IndexPath, CGFloat, UIEdgeInsets) -> CGSize
    func layout(offset: CGPoint,
                width: CGFloat,
                position: ConversationViewLayoutFragmentPosition,
                options: [String:Any],
                sizeCallback: SizeCallback) -> Void
    
    func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]
    func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    
    func indexPathsOfSupplementaryView(ofKind elementKind: String) -> [IndexPath]
    func indexPathsOfDecorationView(ofKind elementKind: String) -> [IndexPath]
}

class ConversationViewLayoutAbstractFragment: ConversationViewLayoutFragment {
    
    init() {
        childFragments = []
        rect = CGRect()
    }
    
    // Child Fragments
    
    var childFragments: [ConversationViewLayoutFragment]
    
    func append(_ fragment: ConversationViewLayoutFragment) {
        childFragments.append(fragment)
    }
    
    // Index Paths
    
    var firstIndexPath: IndexPath? {
        return childFragments.first?.firstIndexPath
    }
    
    var lastIndexPath: IndexPath? {
        return childFragments.first?.lastIndexPath
    }
    
    // Generate Layout
    
    var rect: CGRect
    
    func layout(offset: CGPoint,
                width: CGFloat,
                position: ConversationViewLayoutFragmentPosition,
                options: [String:Any],
                sizeCallback: (IndexPath, CGFloat, UIEdgeInsets) -> CGSize) {
        
        let insets = contentInsets(options)
        let contentWidth = width - (insets.left + insets.right)
        
        var currentOffset = offset
        currentOffset.y = currentOffset.y + insets.top
        currentOffset.x = currentOffset.x + insets.left
        
        for fragment in childFragments {
            fragment.layout(offset: currentOffset,
                            width: contentWidth,
                            position: fragmentPosition(of: fragment),
                            options: options,
                            sizeCallback: sizeCallback)
            
            currentOffset.y = fragment.rect.maxY
            
            if childFragments.last !== fragment  {
                currentOffset.y = currentOffset.y + fragmentSpacing(options)
            }
        }
        
        currentOffset.y = currentOffset.y + insets.bottom
        
        rect = CGRect(origin: offset, size: CGSize(width: width, height: currentOffset.y - offset.y))
    }
    
    func fragmentSpacing(_ options: [String:Any]) -> CGFloat {
        return 0
    }
    
    func contentInsets(_ options: [String:Any]) ->  UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    private func fragmentPosition(of fragment: ConversationViewLayoutFragment) -> ConversationViewLayoutFragmentPosition {
        if childFragments.first === fragment && childFragments.last === fragment {
            return [.first, .last]
        } else if (childFragments.first === fragment) {
            return [.first]
        } else if (childFragments.last === fragment) {
            return [.last]
        } else {
            return []
        }
    }
    
    // Layout Attributes
    
    func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes] {
        var result: [UICollectionViewLayoutAttributes] = []
        for fragment in childFragments {
            if (fragment.rect.intersects(rect)) {
                result.append(contentsOf: fragment.layoutAttributesForElements(in: rect))
            }
        }
        return result
    }
    
    func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        for fragment in childFragments {
            if let result = fragment.layoutAttributesForItem(at: indexPath) {
                return result
            }
        }
        return nil
    }
    
    func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        for fragment in childFragments {
            if let result = fragment.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath) {
                return result
            }
        }
        return nil
    }
    
    func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        for fragment in childFragments {
            if let result = fragment.layoutAttributesForDecorationView(ofKind: elementKind, at: indexPath) {
                return result
            }
        }
        return nil
    }
    
    func indexPathsOfSupplementaryView(ofKind elementKind: String) -> [IndexPath] {
        var result: [IndexPath] = []
        for fragment in childFragments {
            result.append(contentsOf: fragment.indexPathsOfSupplementaryView(ofKind: elementKind))
        }
        return result
    }

    func indexPathsOfDecorationView(ofKind elementKind: String) -> [IndexPath] {
        var result: [IndexPath] = []
        for fragment in childFragments {
            result.append(contentsOf: fragment.indexPathsOfDecorationView(ofKind: elementKind))
        }
        return result
    }
}
