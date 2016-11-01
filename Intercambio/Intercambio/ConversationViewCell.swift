//
//  ConversationViewMessageCell.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 25.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

class ConversationViewCell: UICollectionViewCell {
    
    class func preferredSize(for viewModel: ConversationViewModel,
                             width: CGFloat,
                             layoutMargins: UIEdgeInsets) -> CGSize {
        var size = CGSize(width: width, height: UIFont.preferredFont(forTextStyle: .body).lineHeight)
        size.height = layoutMargins.top + size.height + layoutMargins.bottom
        return size
    }
    
    var viewModel: ConversationViewModel? {
        didSet {
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        let backgroundView = ConversationViewCellBackgroundView(frame: frame)
        backgroundView.cornerRadius = 8.0
        backgroundView.roundedCorners = .allCorners
        backgroundView.borderStyle = .none
        backgroundView.backgroundColor = tintColor
        self.backgroundView = backgroundView
        
        let selectedBackgroundView = ConversationViewCellBackgroundView(frame: frame)
        selectedBackgroundView.cornerRadius = 8.0
        selectedBackgroundView.roundedCorners = .allCorners
        selectedBackgroundView.borderStyle = .none
        selectedBackgroundView.backgroundColor = UIColor.lightGray
        self.selectedBackgroundView = selectedBackgroundView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        backgroundView?.backgroundColor = tintColor
    }
    
    override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            super.isSelected = newValue
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let background = backgroundView as? ConversationViewCellBackgroundView {
            background.backgroundColor = color()
            background.borderColor = borderColor()
            background.roundedCorners = roundedCorners()
            background.borderStyle = borderStyle()
        }
        
        if let background = selectedBackgroundView as? ConversationViewCellBackgroundView {
            background.backgroundColor = selectedColor()
            background.borderColor = borderColor()
            background.roundedCorners = roundedCorners()
            background.borderStyle = borderStyle()
        }
    }
    
    // Colors
    
    func textColor() -> UIColor {
        guard let viewModel = self.viewModel else {
            return UIColor.black
        }
        
        switch viewModel.direction {
        case .inbound:
            return UIColor.black
        case .outbound:
            return viewModel.temporary == true ? UIColor.black : UIColor.white
        default:
            return UIColor.black
        }
    }
    
    func selectedTextColor() -> UIColor {
        guard let viewModel = self.viewModel else {
            return UIColor.gray
        }
        
        switch viewModel.direction {
        case .inbound:
            return UIColor.white
        case .outbound:
            return UIColor.white
        default:
            return UIColor.gray
        }
    }
    
    func borderColor() -> UIColor {
        guard let viewModel = self.viewModel else {
            return UIColor.clear
        }
        
        switch viewModel.direction {
        case .inbound:
            return UIColor.black
        case .outbound:
            return tintColor
        default:
            return tintColor
        }
    }
    
    func color() -> UIColor {
        guard let viewModel = self.viewModel else {
            return UIColor.clear
        }
        
        switch viewModel.direction {
        case .inbound:
            return UIColor(white: 0.87, alpha: 1)
        case .outbound:
            return viewModel.temporary == true ? UIColor.white : tintColor
        default:
            return UIColor.white
        }
    }
    
    func selectedColor() -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        color().getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: hue, saturation: saturation * 0.9, brightness: brightness * 0.7, alpha: alpha)
    }
    
    // Background Corners
    
    func roundedCorners() -> UIRectCorner {
        guard let viewModel = self.viewModel else {
            return [.allCorners]
        }
        
        var corners: UIRectCorner = []
        
        switch viewModel.direction {
        case .inbound:
            corners.insert(.topRight)
            corners.insert(.bottomRight)
            
        case .outbound:
            corners.insert(.topLeft)
            corners.insert(.bottomLeft)
            
        default:
            corners.insert(.allCorners)
        }
        
        if isFirst() {
            corners.insert(.topLeft)
            corners.insert(.topRight)
        }

        if isLast() {
            corners.insert(.bottomLeft)
            corners.insert(.bottomRight)
        }
        
        return corners
    }
    
    func isFirst() -> Bool {
        return position.contains(.first)
    }
    
    func isLast() -> Bool {
        return position.contains(.last)
    }
    
    // Border Style
    
    func borderStyle() -> ConversationViewCellBackgroundView.BorderStyle {
        guard let viewModel = self.viewModel else {
            return .none
        }
        return viewModel.temporary == true ? .dashed : .none
    }
    
    // Layout Attributes 
    
    private var position: ConversationViewLayoutFragmentPosition = []
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        if let attributes = layoutAttributes as? ConversationViewLayoutAttributes {
            position = attributes.position ?? [.first, .last]
            contentView.layoutMargins = attributes.layoutMargins ?? UIEdgeInsets()
        }
        super.apply(layoutAttributes)
    }
}
