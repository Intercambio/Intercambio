//
//  FormItemURLCell.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 13.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

class FormItemURLCell: UITableViewCell, UITextFieldDelegate {
    
    var formItem: FormItem<URL>? {
        didSet {
            updateUserInterface()
        }
    }
    
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.preservesSuperviewLayoutMargins = true
        self.contentView.preservesSuperviewLayoutMargins = true
        self.textField.delegate = self
    }
    
    override func prepareForReuse() {
        formItem = nil
    }
    
    // UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let value = textField.text,
           let url = URL(string: value) {
            if url.scheme != nil && url.path.characters.count > 0 {
                formItem?.value = url
            } else {
                formItem?.value = nil
            }
        } else {
            formItem?.value = nil
        }
        updateUserInterface()
    }
    
    // Update User Interface
    
    private func updateUserInterface() {
        textField.placeholder = formItem?.label
        textField.text = formItem?.value?.absoluteString
    }
}
