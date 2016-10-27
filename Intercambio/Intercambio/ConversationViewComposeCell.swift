//
//  ConversationViewComposeCell.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 25.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

class ConversationViewComposeCell: ConversationViewCell, UITextViewDelegate {
    
    override class func preferredSize(for viewModel: ConversationViewModel,
                                      width: CGFloat,
                                      layoutMargins: UIEdgeInsets) -> CGSize {
        
        if let body = viewModel.body {
            
            let lableWidth = width - (layoutMargins.left + layoutMargins.right)
            let maxHeight = CGFloat.greatestFiniteMagnitude
            let lineHeight = UIFont.preferredFont(forTextStyle: .body).lineHeight
            
            let messageLabel = UILabel()
            messageLabel.numberOfLines = 0
            messageLabel.font = UIFont.preferredFont(forTextStyle: .body)
            messageLabel.preferredMaxLayoutWidth = lableWidth
            messageLabel.attributedText = body
            
            var size = messageLabel.sizeThatFits(CGSize(width: lableWidth, height: maxHeight))
            size.width = width
            size.height = layoutMargins.top + fmax(size.height, lineHeight) + layoutMargins.bottom
            
            size.height = size.height + 5 // UITextView needs some more points
            
            return size
            
        } else {
            return super.preferredSize(for: viewModel, width: width, layoutMargins: layoutMargins)
        }
    }
    
    class ContainerView : UIScrollView {
        override func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
            
        }
    }
    
    let containerView: ContainerView
    let messageTextView: UITextView
    let sendButton: UIButton
    
    override init(frame: CGRect) {
        
        containerView = ContainerView()
        messageTextView = UITextView(frame: frame)
        sendButton = UIButton(type: .system)
        
        super.init(frame: frame)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.isScrollEnabled = false
        containerView.backgroundColor = UIColor.clear
        
        contentView.addSubview(containerView)
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[container]|", options: [], metrics: [:], views: ["container": containerView]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[container]|", options: [], metrics: [:], views: ["container": containerView]))
        
        messageTextView.delegate = self
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
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.titleLabel?.font = UIFont(name: "FontAwesome", size: 22)
        sendButton.setTitle("", for: .normal)
        sendButton.addTarget(self, action: #selector(send), for: .touchUpInside)
        contentView.addSubview(sendButton)
        
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .left, relatedBy: .equal, toItem: sendButton, attribute: .right, multiplier: 1, constant: 4))
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: sendButton, attribute: .bottom, multiplier: 1, constant: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        messageTextView.selectedRange = NSRange(location: 0, length: 0)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let view = super.hitTest(point, with: event) {
            return view
        } else {
            let convertedPoint = sendButton.convert(point, from: self)
            return sendButton.hitTest(convertedPoint, with: event)
        }
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        containerView.contentSize = layoutAttributes.size
        super.apply(layoutAttributes)
    }
    
    // View Model
    
    override var viewModel: ConversationViewModel? {
        didSet {
            messageTextView.attributedText = viewModel?.body
        }
    }
    
    // Action
    
    @objc func send() {
        performAction(#selector(send), sender: self)
    }
    
    // UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        handle([.editingDidBegin], sender: textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        handle([.editingChanged], sender: textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        handle([.editingDidEnd], sender: textView)
    }
}
