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

class ConversationViewCell: UICollectionViewCell {
    
    class func preferredSize(
        for viewModel: ConversationViewModel,
        width: CGFloat,
        layoutMargins: UIEdgeInsets
    ) -> CGSize {
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
        setNeedsLayout()
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
        
        if viewModel.type == .error {
            return #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        } else {
            switch viewModel.direction {
            case .inbound:
                return UIColor.black
            case .outbound:
                return viewModel.temporary == true ? UIColor.black : UIColor.white
            default:
                return UIColor.black
            }
        }
    }
    
    func selectedTextColor() -> UIColor {
        return UIColor.white
    }
    
    func borderColor() -> UIColor {
        guard let viewModel = self.viewModel else {
            return UIColor.clear
        }
        
        if viewModel.type == .emoji {
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
        
        if viewModel.type == .emoji {
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
