//
//  ConversationViewComposeCell.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 25.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

class ConversationViewComposeCell: ConversationViewCell {
    
    class ContainerView : UIScrollView {
        override func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
            
        }
    }
    
    let containerView: ContainerView
    let messageTextView: UITextView
    
    override init(frame: CGRect) {
        
        containerView = ContainerView()
        messageTextView = UITextView(frame: frame)
        
        super.init(frame: frame)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.isScrollEnabled = false
        containerView.backgroundColor = UIColor.clear
        
        contentView.addSubview(containerView)
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[container]|", options: [], metrics: [:], views: ["container": containerView]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[container]|", options: [], metrics: [:], views: ["container": containerView]))
        
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        messageTextView.isScrollEnabled = false
        messageTextView.textContainer.lineFragmentPadding = 0
        messageTextView.textContainerInset = UIEdgeInsets()
        messageTextView.backgroundColor = UIColor.clear
        messageTextView.font = UIFont.preferredFont(forTextStyle: .body)
        containerView.addSubview(messageTextView)

        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .topMargin, relatedBy: .equal, toItem: messageTextView, attribute: .top, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .bottomMargin, relatedBy: .equal, toItem: messageTextView, attribute: .bottom, multiplier: 1, constant: 0))
        
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .leftMargin, relatedBy: .equal, toItem: messageTextView, attribute: .left, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .rightMargin, relatedBy: .equal, toItem: messageTextView, attribute: .right, multiplier: 1, constant: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        messageTextView.selectedRange = NSRange(location: 0, length: 0)
    }
    
    override var viewModel: ConversationViewModel? {
        didSet {
            messageTextView.attributedText = viewModel?.body
        }
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        containerView.contentSize = layoutAttributes.size
        super.apply(layoutAttributes)
    }
}
