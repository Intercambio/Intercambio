//
//  OptionPicker.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 30.10.16.
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

protocol OptionPickerItem : Equatable {
    var title: String { get }
}

class OptionPicker<I : OptionPickerItem> : UIControl, UIKeyInput, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var name: String? {
        didSet {
            updateLabels()
        }
    }
    
    var options: [I]? {
        didSet {
            optionsPickerView.reloadAllComponents()
            updateLabels()
        }
    }
    
    var indexOfSelectedOption: Int? {
        didSet {
            if let row = indexOfSelectedOption {
                optionsPickerView.selectRow(row, inComponent: 0, animated: false)
            }
            updateLabels()
        }
    }

    let nameLabel: UILabel
    let valueLabel: UILabel
    
    var showBottomBorder: Bool = true {
        didSet {
            borderView.isHidden = !showBottomBorder
        }
    }
    
    private let optionsPickerView: UIPickerView
    private let borderView: UIView
    
    override init(frame: CGRect) {
        
        nameLabel = UILabel()
        valueLabel = UILabel()
        optionsPickerView = UIPickerView()
        borderView = UIView()
        
        super.init(frame: frame)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .horizontal)
        nameLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, for: .horizontal)
        nameLabel.textColor = UIColor.lightGray
        
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.setContentHuggingPriority(UILayoutPriorityDefaultLow, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .horizontal)
        valueLabel.textColor = tintColor
        
        optionsPickerView.translatesAutoresizingMaskIntoConstraints = false
        optionsPickerView.showsSelectionIndicator = true
        optionsPickerView.dataSource = self
        optionsPickerView.delegate = self
        
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = UIColor.lightGray
        
        let stackView = UIStackView(arrangedSubviews: [nameLabel, valueLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.spacing = 6
        addSubview(stackView)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[stack]-|", options: [], metrics: [:], views: ["stack":stackView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[stack]", options: [], metrics: [:], views: ["stack":stackView]))
        
        let bottomConstraint = NSLayoutConstraint(item: stackView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottomMargin, multiplier: 1, constant: 0)
        bottomConstraint.priority = 999
        addConstraint(bottomConstraint)
        
        addSubview(borderView)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[border]|", options: [], metrics: [:], views: ["border":borderView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[border(==0.5)]|", options: [], metrics: [:], views: ["border":borderView]))
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        addGestureRecognizer(recognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        valueLabel.textColor = tintColor
    }
    
    // Handle Gesture
    
    @objc private func onTap(_ gesture: UITapGestureRecognizer) {
        if isFirstResponder {
            let _ = resignFirstResponder()
        } else {
            let _ = becomeFirstResponder()
        }
    }
    
    // Update Label
    
    private func updateLabels() {
        nameLabel.text = name
        nameLabel.isHidden = name == nil
        valueLabel.text = selectedOption()?.title
    }
    
    private func selectedOption() -> I? {
        if let index = indexOfSelectedOption {
            if index >= 0 && index < options?.count ?? 0 {
                return options?[index]
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    // UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options?.count ?? 0
    }
    
    // UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let item = options?[row] {
            return item.title
        } else {
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        indexOfSelectedOption = row
        sendActions(for: [.valueChanged])
    }
    
    // UIKeyInput
    
    var hasText: Bool { return true }
    func insertText(_ text: String) {}
    func deleteBackward() {}
    
    // UIResponder
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputView: UIView? {
        return optionsPickerView
    }
}
