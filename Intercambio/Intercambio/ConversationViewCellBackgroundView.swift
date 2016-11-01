//
//  ConversationViewCellBackgroundView.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 25.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

class ConversationViewCellBackgroundView: UIView {

    enum BorderStyle {
        case none
        case solid
        case dashed
    }
    
    var cornerRadius: CGFloat = 5.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var roundedCorners: UIRectCorner = .allCorners {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var borderColor: UIColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)  {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var borderStyle: BorderStyle = .dashed  {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var customBackgroundColor: UIColor?
    override var backgroundColor: UIColor? {
        get {
            return customBackgroundColor
        }
        set {
            customBackgroundColor = newValue
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        super.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let borderRect = bounds.insetBy(dx: 1, dy: 1)
        let path = UIBezierPath(roundedRect: borderRect,
                                byRoundingCorners: roundedCorners,
                                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        path.lineCapStyle = .round
        path.lineWidth = 2
        
        borderColor.setStroke()
        (backgroundColor ?? UIColor.clear).setFill()
        
        switch borderStyle {
        case .solid:
            path.stroke()
            path.fill()
            
        case .dashed:
            let pattern: [CGFloat] = [4, 5]
            path.setLineDash(pattern, count: 2, phase: 0)
            path.stroke()
            path.fill()
            
        default:
            path.fill()
        }
    }
}
