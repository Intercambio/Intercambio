//
//  NavigationBar.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 02.08.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

class NavigationBar : UINavigationBar {
    
    let contentView: UIStackView
    
    override init(frame: CGRect) {
        contentView = UIStackView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.axis = .vertical
        contentView.alignment = .fill
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func triggerLayoutUpdate() {
        if let navigationController = self.delegate as? UINavigationController {
            if !navigationController.isNavigationBarHidden {
                navigationController.isNavigationBarHidden = true
                navigationController.isNavigationBarHidden = false
            }
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var navigationBarSize = super.sizeThatFits(size)
        let contentViewSize = contentView.sizeThatFits(CGSize(width: size.width, height: 0))
        navigationBarSize.height += contentViewSize.height
        return navigationBarSize
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let contentViewSize = contentView.sizeThatFits(CGSize(width: self.bounds.size.width, height: 0))
        contentView.frame = CGRect(origin: self.bounds.origin,
                                   size: CGSize(width: self.bounds.size.width,
                                                height: contentViewSize.height))
    }
}
