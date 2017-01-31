//
//  AvatarView.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 18.10.16.
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

class AvatarView: UIImageView {

    private var defaultImage: UIImageView?

    override func layoutSubviews() {
        if defaultImage == nil {
            let bundle = Bundle(for: AvatarView.self)
            defaultImage = UIImageView(image: UIImage(named: "avatar-normal", in: bundle, compatibleWith: nil))
            defaultImage?.translatesAutoresizingMaskIntoConstraints = false
            defaultImage?.backgroundColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
            defaultImage?.tintColor = #colorLiteral(red: 0.9344148174, green: 0.9412353635, blue: 0.9412353635, alpha: 1)
            defaultImage?.contentMode = .scaleAspectFit
            addSubview(defaultImage!)
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: [:], views: ["view":defaultImage!]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: [:], views: ["view":defaultImage!]))
        }
        clipsToBounds = true
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2.0
        defaultImage?.layer.cornerRadius = layer.cornerRadius
        defaultImage?.isHidden = image != nil
    }
}
