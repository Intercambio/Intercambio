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
}
