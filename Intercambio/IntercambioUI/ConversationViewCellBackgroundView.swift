//
//  ConversationViewCellBackgroundView.swift
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
    
    var borderColor: UIColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var borderStyle: BorderStyle = .dashed {
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
        let path = UIBezierPath(
            roundedRect: borderRect,
            byRoundingCorners: roundedCorners,
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
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
