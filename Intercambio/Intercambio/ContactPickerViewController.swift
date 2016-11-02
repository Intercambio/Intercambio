//
//  ContactPickerViewController.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 30.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

public class ContactPickerViewController: UIViewController, CLTokenInputViewDelegate, ContactPickerView, ContentView {

    private class View : UIView {
        let contentView: UIView
        override init(frame: CGRect) {
            contentView = UIView()
            contentView.translatesAutoresizingMaskIntoConstraints = false
            super.init(frame: frame)
            addSubview(contentView)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            if contentView.frame.contains(point) {
                return super.hitTest(point, with: event)
            } else {
                return nil
            }
        }
    }
    
    var eventHandler: ContectPickerViewEventHandler?
    
    var selectedAccount: ContactPickerAddress? {
        didSet {
            updateAccounts()
        }
    }
    
    var accounts: [ContactPickerAddress]? {
        didSet {
            updateAccounts()
        }
    }
    
    var contentView: UIView? {
        if let view = self.view as? View {
            return view.contentView
        } else {
            return nil
        }
    }
    
    private var backgroundView: UIVisualEffectView?
    private var searchBar: CLTokenInputView?
    private var accountPicker: OptionPicker<ContactPickerAddress>?
    
    public override func loadView() {
        let view = View()
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view = view
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|",
                                                           options: [],
                                                           metrics: [:],
                                                           views: ["contentView": view.contentView]))
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[top][contentView]",
                                                           options: [],
                                                           metrics: [:],
                                                           views: ["contentView": view.contentView,
                                                                   "top": topLayoutGuide]))
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if let contentView = self.contentView {
            
            let searchBar = setupSearchBar()
            let accountPicker = setupAccountPicker()
            
            let stackView = UIStackView(arrangedSubviews: [searchBar, accountPicker])
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.alignment = .fill
            
            contentView.addSubview(stackView)
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackView]|",
                                                                      options: [],
                                                                      metrics: [:],
                                                                      views: ["stackView":stackView]))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]|",
                                                                      options: [],
                                                                      metrics: [:],
                                                                      views: ["stackView":stackView]))
        }
        
        setupBackgroundView()
        
        updateAccounts()
    }
    
    private func setupSearchBar() -> UIView {
        let searchBar = CLTokenInputView()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundColor = UIColor.clear
        searchBar.keyboardType = .emailAddress
        searchBar.placeholderText = "Enter Address"
        searchBar.drawBottomBorder = true
        searchBar.delegate = self
        
        self.searchBar = searchBar
        
        return searchBar
    }
    
    private func setupAccountPicker() -> UIView {
        let accountPicker = OptionPicker<ContactPickerAddress>()
        accountPicker.preservesSuperviewLayoutMargins = false
        accountPicker.layoutMargins = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        accountPicker.name = "via"
        
        accountPicker.addTarget(self, action: #selector(accountDidChange(_:)), for: [.valueChanged])
        
        self.accountPicker = accountPicker
        
        return accountPicker
    }
    
    private func setupBackgroundView() {
        if let contentView = self.contentView {
            
            let effect = UIBlurEffect(style: .extraLight)
            let backgroundView = UIVisualEffectView(effect: effect)
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            
            view.insertSubview(backgroundView, belowSubview: contentView)
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroundView]|",
                                                               options: [],
                                                               metrics: [:],
                                                               views: ["backgroundView": backgroundView]))
            
            view.addConstraint(NSLayoutConstraint(item: contentView,
                                                  attribute: .top,
                                                  relatedBy: .equal,
                                                  toItem: backgroundView,
                                                  attribute: .top,
                                                  multiplier: 1,
                                                  constant: 0))
            
            view.addConstraint(NSLayoutConstraint(item: contentView,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: backgroundView,
                                                  attribute: .bottom,
                                                  multiplier: 1,
                                                  constant: 0))
            
            self.backgroundView = backgroundView
        }
    }
    
    private func updateAccounts() {
        accountPicker?.options = accounts
        accountPicker?.indexOfSelectedOption = selectedAccount != nil ? accounts?.index(of: selectedAccount!) : nil
        accountPicker?.isHidden = accounts?.count ?? 0 < 2
    }
    
    @objc private func accountDidChange(_ sender: Any?) {
        if let index = accountPicker?.indexOfSelectedOption,
           let options = accountPicker?.options {
            let account = options[index]
            selectedAccount = account
            eventHandler?.didSelectAccount(account)
        } else {
            selectedAccount = nil
            eventHandler?.didSelectAccount(nil)
        }
    }
    
    // CLTokenInputViewDelegate
    
    public func tokenInputView(_ view: CLTokenInputView, tokenForText text: String) -> CLToken? {
        if let address = eventHandler?.addressFor(text) {
            return CLToken(displayText: address.title, context: address)
        } else {
            return nil
        }
    }
    
    public func tokenInputView(_ view: CLTokenInputView, didAdd token: CLToken) {
        if let address = token.context as? ContactPickerAddress {
            eventHandler?.didAdd(address)
        }
    }
    
    public func tokenInputView(_ view: CLTokenInputView, didRemove token: CLToken) {
        if let address = token.context as? ContactPickerAddress {
            eventHandler?.didRemove(address)
        }
    }
}

extension ContactPickerAddress : OptionPickerItem {}
