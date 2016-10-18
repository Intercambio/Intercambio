//
//  AvatarView.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 18.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

class AvatarView: UIImageView {

    private var defaultImage: UIImageView?

    override func layoutSubviews() {
        if defaultImage == nil {
            defaultImage = UIImageView(image: UIImage(named: "avatar-normal"))
            defaultImage?.backgroundColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
            defaultImage?.tintColor = #colorLiteral(red: 0.9344148174, green: 0.9412353635, blue: 0.9412353635, alpha: 1)
            addSubview(defaultImage!)
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: [:], views: ["view":defaultImage!]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: [:], views: ["view":defaultImage!]))
        }
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2.0
        defaultImage?.layer.cornerRadius = layer.cornerRadius
        defaultImage?.isHidden = image != nil
    }
}
