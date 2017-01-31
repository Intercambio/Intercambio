//
//  NavigationBarStatusView.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 05.08.16.
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

class NavigationBarStatusView: UIControl {
    
    var status: NavigationControllerStatusViewModel? {
        didSet {
            button.setTitle(status?.title, for: .normal)
        }
    }
    
    private let icon: UILabel
    private let button: UIButton
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        icon = UILabel()
        icon.translatesAutoresizingMaskIntoConstraints = false
        button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        super.init(frame: frame)
        
        button.addTarget(self, action: #selector(didTap(sender:)), for: .touchUpInside)
        self.addSubview(button)
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[button]|",
                                                           metrics: nil,
                                                           views: ["button": button]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[button]|",
                                                           metrics: nil,
                                                           views: ["button": button]))
        
        icon.text = ""
        icon.font = UIFont(name: "FontAwesome", size: 14)
        icon.textColor = UIColor.lightGray
        self.addSubview(icon)
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[icon]-(==6)-[button]",
                                                           metrics: nil,
                                                           views: ["icon": icon, "button": button]))
        self.addConstraint(NSLayoutConstraint(item: icon,
                                              attribute: .firstBaseline,
                                              relatedBy: .equal,
                                              toItem: button,
                                              attribute: .firstBaseline,
                                              multiplier: 1,
                                              constant: 0))
    }
    
    func didTap(sender: AnyObject) {
        sendActions(for: .touchUpInside)
    }
}
