//
//  ConversationViewComposeCell.swift
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
    
    override var canBecomeFirstResponder: Bool {
        return messageTextView.canBecomeFirstResponder
    }
    
    override var isFirstResponder: Bool {
        return messageTextView.isFirstResponder
    }
    
    override func becomeFirstResponder() -> Bool {
        return messageTextView.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        return messageTextView.resignFirstResponder()
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        containerView.contentSize = layoutAttributes.size
        super.apply(layoutAttributes)
    }
    
    // View Model
    
    override var viewModel: ConversationViewModel? {
        didSet {
            messageTextView.attributedText = viewModel?.body
            updateButtonState()
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
        updateButtonState()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        handle([.editingDidEnd], sender: textView)
    }
    
    // Button
    
    private func updateButtonState() {
        sendButton.isEnabled = hasContent()
        sendButton.isHidden = !hasContent()
    }
    
    private func hasContent() -> Bool {
        return messageTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count > 0
    }
}
