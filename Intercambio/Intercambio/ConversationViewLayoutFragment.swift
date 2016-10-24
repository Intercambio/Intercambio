//
//  ConversationViewLayoutFragment.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 24.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
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
}
