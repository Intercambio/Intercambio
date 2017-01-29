//
//  ConversationViewMessageCell.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 25.10.16.
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

class ConversationViewMessageCell: ConversationViewCell {
    
    override class func preferredSize(for viewModel: ConversationViewModel,
                                      width: CGFloat,
                                      layoutMargins: UIEdgeInsets) -> CGSize {
        
        if let body = viewModel.body {
            
            let lableWidth = width - (layoutMargins.left + layoutMargins.right)
            let maxHeight = CGFloat(500)
            
            let messageLabel = UILabel()
            messageLabel.numberOfLines = 0
            messageLabel.preferredMaxLayoutWidth = lableWidth
            
            if viewModel.type == .emoji {
                messageLabel.text = body.string
                messageLabel.font = UIFont.systemFont(ofSize: 90)
            } else {
                messageLabel.attributedText = body
                messageLabel.font = UIFont.preferredFont(forTextStyle: .body)
            }
            
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
            if viewModel?.type == .emoji {
                messageLabel.font = UIFont.systemFont(ofSize: 90)
                messageLabel.text = viewModel?.body?.string
            } else {
                messageLabel.font = UIFont.preferredFont(forTextStyle: .body)
                messageLabel.attributedText = viewModel?.body
            }
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
