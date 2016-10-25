//
//  ConversationViewLayoutAttributes.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 24.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

class ConversationViewLayoutAttributes: UICollectionViewLayoutAttributes {
    var alignment: ConversationViewLayoutFragmentAlignment?
    var position: ConversationViewLayoutFragmentPosition?
    var maxWidth: CGFloat?
    var layoutMargins: UIEdgeInsets?
    var timestamp: Date?
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let attributes = super.copy(with: zone) as! ConversationViewLayoutAttributes
        attributes.alignment = alignment
        attributes.position = position
        attributes.maxWidth = maxWidth
        attributes.layoutMargins = layoutMargins
        attributes.timestamp = timestamp
        return attributes
    }
}
