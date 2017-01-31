//
//  NavigationBar.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 02.08.16.
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

public class NavigationBar : UINavigationBar {
    
    let contentView: UIStackView
    
    override init(frame: CGRect) {
        contentView = UIStackView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.axis = .vertical
        contentView.alignment = .center
        super.init(frame: frame)
        self.addSubview(contentView)
        
        var constraints: [NSLayoutConstraint] = []
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|",
                                                                      metrics: nil,
                                                                      views: ["contentView": contentView]))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[contentView]",
                                                                      metrics: nil,
                                                                      views: ["contentView": contentView]))
        addConstraints(constraints)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        var navigationBarSize = super.sizeThatFits(size)
        let contentViewSize = contentView.sizeThatFits(CGSize(width: size.width, height: 0))
        navigationBarSize.height += contentViewSize.height
        return navigationBarSize
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        let contentViewSize = contentView.sizeThatFits(CGSize(width: self.bounds.size.width, height: 0))
        contentView.frame = CGRect(origin: self.bounds.origin,
                                   size: CGSize(width: self.bounds.size.width,
                                                height: contentViewSize.height))
    }
    
    func triggerLayoutUpdate() {
        if let navigationController = self.delegate as? UINavigationController {
            if !navigationController.isNavigationBarHidden {
                navigationController.isNavigationBarHidden = true
                navigationController.isNavigationBarHidden = false
            }
        }
    }
}

public extension NavigationBar {
    public func make() -> NavigationBar {
        return NavigationBar()
    }
}
