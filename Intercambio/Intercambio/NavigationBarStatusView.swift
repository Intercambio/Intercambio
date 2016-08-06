//
//  NavigationBarStatusView.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 05.08.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
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
