//
//  ContactPickerPresenter.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 01.11.16.
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
import IntercambioCore
import CoreXMPP

protocol ContactPickerPresenterEventHandler {
    func didChange(conversation uri: URL?) -> Void
}

class ContactPickerPresenter: NSObject, ContectPickerViewEventHandler {
    
    let accountManager: AccountManager
    init(accountManager: AccountManager) {
        self.accountManager = accountManager
        super.init()
        registerNotificationObservers()
        updateAccounts()
    }
    
    deinit {
        unregisterNotificationObservers()
    }
    
    weak var view: ContactPickerView? {
        didSet {
            updateView()
        }
    }
    
    var eventHandler: ContactPickerPresenterEventHandler?
    
    var account: JID?
    var accounts: [JID]?
    var counterparts: NSMutableOrderedSet = NSMutableOrderedSet()
    
    var conversationURI: URL? {
        set {
            account = nil
            counterparts.removeAllObjects()
            if let uri = newValue {
                if let components = NSURLComponents(url: uri, resolvingAgainstBaseURL: true) {
                    if components.scheme == "xmpp" {
                        if let host = components.host, let user = components.user {
                            account = JID(user: user, host: host, resource: nil)
                        }
                    }
                    if let string = uri.pathComponents.last {
                        if let jid = JID(string) {
                            counterparts.add(jid)
                        }
                    }
                }
            }
            if account == nil {
                account = accountManager.accounts.first
            }
            updateView()
            postContactDidChangeNotification()
        }
        get {
            if let account = self.account {
                
                if counterparts.count != 1 {
                    return nil
                } else if let counterpart = counterparts.firstObject as? JID {
                    
                    // account
                    var components = URLComponents()
                    components.scheme = "xmpp"
                    components.host = account.host
                    components.user = account.user
                    
                    // counterpart
                    components.path = "/\(counterpart.bare().stringValue)"
                    
                    return components.url
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
    }
    
    func didSelectAccount(_ account: ContactPickerAddress?) {
        self.account = account?.jid
        postContactDidChangeNotification()
    }
    
    func addressFor(_ text: String) -> ContactPickerAddress? {
        if let jid = JID(text) {
            return ContactPickerAddress(jid)
        } else {
            return nil
        }
    }
    
    func didRemove(_ address: ContactPickerAddress) {
        counterparts.remove(address.jid)
        postContactDidChangeNotification()
        updateView()
    }
    
    func didAdd(_ address: ContactPickerAddress) {
        counterparts.add(address.jid)
        postContactDidChangeNotification()
        updateView()
    }
    
    private func postContactDidChangeNotification() {
        eventHandler?.didChange(conversation: conversationURI)
    }
    
    private func updateAccounts() {
        self.accounts = accountManager.accounts
        if account == nil {
            account = accountManager.accounts.first
        }
        updateView()
    }
    
    private func updateView() {
        if let view = self.view {
            
            var accountAddresses: [ContactPickerAddress] = []
            if let jids = accounts {
                for jid in jids {
                    accountAddresses.append(ContactPickerAddress(jid))
                }
            }
            view.accounts = accountAddresses
            
            if let jid = account {
                view.selectedAccount = ContactPickerAddress(jid)
            } else {
                view.selectedAccount = nil
            }
            
            var counterpartAddresses: [ContactPickerAddress] = []
            for counterpart in counterparts {
                if let jid = counterpart as? JID {
                    counterpartAddresses.append(ContactPickerAddress(jid))
                }
            }
            view.addresses = counterpartAddresses
        }
    }
    
    // Notification Handling
    
    private lazy var notificationObservers = [NSObjectProtocol]()
    
    private func registerNotificationObservers() {
        let center = NotificationCenter.default
        
        notificationObservers.append(center.addObserver(
            forName: NSNotification.Name(rawValue: AccountManagerDidAddAccount),
            object: accountManager,
            queue: OperationQueue.main
        ) { [weak self] _ in
            self?.updateAccounts()
        })
        
        notificationObservers.append(center.addObserver(
            forName: NSNotification.Name(rawValue: AccountManagerDidRemoveAccount),
            object: accountManager,
            queue: OperationQueue.main
        ) { [weak self] _ in
            self?.updateAccounts()
        })
    }
    
    private func unregisterNotificationObservers() {
        let center = NotificationCenter.default
        for observer in notificationObservers {
            center.removeObserver(observer)
        }
        notificationObservers.removeAll()
    }
}
