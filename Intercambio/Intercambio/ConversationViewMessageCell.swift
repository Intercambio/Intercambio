//
//  ConversationViewMessageCell.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 25.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

class ConversationViewMessageCell: ConversationViewCell {
    
    override class func preferredSize(for viewModel: ConversationViewModel,
                                      width: CGFloat,
                                      layoutMargins: UIEdgeInsets) -> CGSize {
        
        if let body = viewModel.body {
            
            let lableWidth = width - (layoutMargins.left + layoutMargins.right)
            let maxHeight = CGFloat(500)
            
            let messageLabel = UILabel()
            messageLabel.numberOfLines = 0
            messageLabel.font = UIFont.preferredFont(forTextStyle: .body)
            messageLabel.preferredMaxLayoutWidth = lableWidth
            messageLabel.attributedText = body
            
            var size = messageLabel.sizeThatFits(CGSize(width: lableWidth, height: maxHeight))
            size.width = layoutMargins.left + size.width + layoutMargins.right
            size.height = layoutMargins.top + size.height + layoutMargins.bottom
            
            return size
            
        } else {
            return super.preferredSize(for: viewModel, width: width, layoutMargins: layoutMargins)
        }
    }
    
    override var viewModel: ConversationViewModel? {
        didSet {
            messageLabel.attributedText = viewModel?.body
        }
    }
    
    var messageLabel: UILabel
    
    override init(frame: CGRect) {
        messageLabel = UILabel()
        super.init(frame: frame)
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.backgroundColor = UIColor.clear
        messageLabel.textColor = textColor()
        messageLabel.font = UIFont.preferredFont(forTextStyle: .body)
        
        contentView.addSubview(messageLabel)
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[message]-|", options: [], metrics: [:], views: ["message": messageLabel]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[message]-|", options: [], metrics: [:], views: ["message": messageLabel]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isSelected {
            messageLabel.textColor = selectedTextColor()
        } else {
            messageLabel.textColor = textColor()
        }
    }
}
