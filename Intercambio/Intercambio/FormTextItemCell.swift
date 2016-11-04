//
//  FormTextItemCell.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 04.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

class FormTextItemCell: UITableViewCell, UITextFieldDelegate {

    public static var predicate: NSPredicate {
        return NSPredicate(block: { (item, options) -> Bool in
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
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[textField]-|",
                                                      options: [],
                                                      metrics: [:],
                                                      views: ["textField":textField]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[textField]-|",
                                                      options: [],
                                                      metrics: [:],
                                                      views: ["textField":textField]))
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
