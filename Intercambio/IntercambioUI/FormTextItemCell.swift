//
//  FormTextItemCell.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 04.11.16.
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

class FormTextItemCell: UITableViewCell, UITextFieldDelegate {
    
    public static var predicate: NSPredicate {
        return NSPredicate(block: { (item, _) -> Bool in
            return item is FormTextItem
        })
    }
    
    public let textField: UITextField
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        textField = UITextField()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        preservesSuperviewLayoutMargins = true
        contentView.preservesSuperviewLayoutMargins = true
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.returnKeyType = .done
        textField.keyboardType = .default
        
        addSubview(textField)
        addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-[textField]-|",
            options: [],
            metrics: [:],
            views: ["textField": textField]
        ))
        addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-[textField]-|",
            options: [],
            metrics: [:],
            views: ["textField": textField]
        ))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var item: FormTextItem? {
        didSet {
            textField.placeholder = item?.placeholder
            textField.text = item?.text
        }
    }
    
    // UITextFieldDelegate
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            setValue(text.characters.count > 0 ? text : nil, sender: self)
        } else {
            setValue(nil, sender: self)
        }
    }
}
