//
//  ConversationViewGroupHeaderView.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 24.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

class ConversationViewGroupHeaderView: UICollectionReusableView {
    
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    let label: UILabel
    
    override init(frame: CGRect) {
        label = UILabel()
        super.init(frame: frame)
        
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.textAlignment = .center
        label.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        if let attributes = layoutAttributes as? ConversationViewLayoutAttributes {
            if let timestamp = attributes.timestamp {
                let formatter = ConversationViewGroupHeaderView.dateFormatter
                label.text = formatter.string(for: timestamp)
            } else {
                label.text = "Now"
            }
        }
        super.apply(layoutAttributes)
    }
}
