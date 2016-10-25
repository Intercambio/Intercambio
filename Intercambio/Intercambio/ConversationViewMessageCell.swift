//
//  ConversationViewMessageCell.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 25.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

class ConversationViewMessageCell: UICollectionViewCell {
    
    var position: ConversationViewLayoutFragmentPosition = []
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let background = backgroundView as? ConversationViewCellBackgroundView {
            background.backgroundColor = backgroundColor()
            background.borderColor = borderColor()
            background.roundedCorners = roundedCorners()
        }
        
        if let background = selectedBackgroundView as? ConversationViewCellBackgroundView {
            background.backgroundColor = selectedbckgroundColor()
            background.borderColor = borderColor()
            background.roundedCorners = roundedCorners()
        }
        
        if isSelected {
            
        } else {
            
        }
    }
    
    // Colors
    
    private func textColor() -> UIColor {
        return UIColor.black
    }
    
    private func selectedTextColor() -> UIColor {
        return UIColor.black
    }
    
    private func borderColor() -> UIColor {
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
    
    private func backgroundColor() -> UIColor {
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
    
    private func selectedbckgroundColor() -> UIColor {
        let color = backgroundColor()
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: hue, saturation: saturation * 0.9, brightness: brightness * 0.7, alpha: alpha)
    }
    
    // Background Corners
    
    private func roundedCorners() -> UIRectCorner {
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
    
    private func isFirst() -> Bool {
        return position.contains(.first)
    }
    
    private func isLast() -> Bool {
        return position.contains(.last)
    }
    
    // Layout Attributes 
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        if let attributes = layoutAttributes as? ConversationViewLayoutAttributes {
            position = attributes.position ?? [.first, .last]
        }
        super.apply(layoutAttributes)
    }
}
