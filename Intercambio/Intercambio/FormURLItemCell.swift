//
//  FormURLItemCell.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 03.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

public class FormURLItemCell: UITableViewCell, UITextFieldDelegate {
    
    public static var predicate: NSPredicate {
        return NSPredicate(block: { (item, options) -> Bool in
            return item is FormURLItem
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
        textField.keyboardType = .URL
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        
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
    
    public var item: FormURLItem? {
        didSet {
            textField.placeholder = item?.placeholder
            textField.text = item?.url?.absoluteString
        }
    }
    
    // UITextFieldDelegate
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text,
            let url = URL(string: text) {
            setValue(url, sender: self)
        } else {
            setValue(nil, sender: self)
        }
    }
}
