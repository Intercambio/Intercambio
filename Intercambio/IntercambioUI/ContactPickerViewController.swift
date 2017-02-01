//
//  ContactPickerViewController.swift
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

public class ContactPickerViewController: UIViewController, CLTokenInputViewDelegate, ContactPickerView, ContentView {
    
    private class View: UIView {
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
    
    var presenter: ContectPickerViewEventHandler?
    
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
    
    var addresses: [ContactPickerAddress]? {
        didSet {
            updateAddresses()
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
        
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[contentView]|",
            options: [],
            metrics: [:],
            views: ["contentView": view.contentView]
        ))
        
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[top][contentView]",
            options: [],
            metrics: [:],
            views: [
                "contentView": view.contentView,
                "top": topLayoutGuide
            ]
        ))
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
            contentView.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[stackView]|",
                options: [],
                metrics: [:],
                views: ["stackView": stackView]
            ))
            contentView.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[stackView]|",
                options: [],
                metrics: [:],
                views: ["stackView": stackView]
            ))
        }
        
        setupBackgroundView()
        
        updateAccounts()
        updateAddresses()
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
            view.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[backgroundView]|",
                options: [],
                metrics: [:],
                views: ["backgroundView": backgroundView]
            ))
            
            view.addConstraint(NSLayoutConstraint(
                item: contentView,
                attribute: .top,
                relatedBy: .equal,
                toItem: backgroundView,
                attribute: .top,
                multiplier: 1,
                constant: 0
            ))
            
            view.addConstraint(NSLayoutConstraint(
                item: contentView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: backgroundView,
                attribute: .bottom,
                multiplier: 1,
                constant: 0
            ))
            
            self.backgroundView = backgroundView
        }
    }
    
    private func updateAccounts() {
        accountPicker?.options = accounts
        accountPicker?.indexOfSelectedOption = selectedAccount != nil ? accounts?.index(of: selectedAccount!) : nil
        accountPicker?.isHidden = accounts?.count ?? 0 < 2
    }
    
    @objc private func accountDidChange(_: Any?) {
        if let index = accountPicker?.indexOfSelectedOption,
            let options = accountPicker?.options {
            let account = options[index]
            selectedAccount = account
            presenter?.didSelectAccount(account)
        } else {
            selectedAccount = nil
            presenter?.didSelectAccount(nil)
        }
    }
    
    private func updateAddresses() {
        searchBar?.removeAllTokens()
        if let addresses = self.addresses {
            for address in addresses {
                searchBar?.add(CLToken(displayText: address.title, context: address))
            }
        }
    }
    
    // CLTokenInputViewDelegate
    
    public func tokenInputView(_ view: CLTokenInputView, tokenForText text: String) -> CLToken? {
        if let address = presenter?.addressFor(text) {
            return CLToken(displayText: address.title, context: address)
        } else {
            return nil
        }
    }
    
    public func tokenInputView(_: CLTokenInputView, didAdd token: CLToken) {
        if let address = token.context as? ContactPickerAddress {
            presenter?.didAdd(address)
        }
    }
    
    public func tokenInputView(_: CLTokenInputView, didRemove token: CLToken) {
        if let address = token.context as? ContactPickerAddress {
            presenter?.didRemove(address)
        }
    }
}

extension ContactPickerAddress: OptionPickerItem {}
