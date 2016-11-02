//
//  ContactPickerPresenter.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 01.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import IntercambioCore
import  CoreXMPP

protocol ContactPickerPresenterEventHandler {
    func didChange(conversation uri: URL?) -> Void
}

class ContactPickerPresenter : NSObject, ContectPickerViewEventHandler {

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
    }
    
    func didAdd(_ address: ContactPickerAddress) {
        counterparts.add(address.jid)
        postContactDidChangeNotification()
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
        }
    }
    
    // Notification Handling
    
    private lazy var notificationObservers = [NSObjectProtocol]()
    
    private func registerNotificationObservers() {
        let center = NotificationCenter.default
        
        notificationObservers.append(center.addObserver(forName: NSNotification.Name(rawValue: AccountManagerDidAddAccount),
                                                        object: accountManager,
                                                        queue: OperationQueue.main) { [weak self] (notification) in
                                                            self?.updateAccounts()
        })
        
        notificationObservers.append(center.addObserver(forName: NSNotification.Name(rawValue: AccountManagerDidRemoveAccount),
                                                        object: accountManager,
                                                        queue: OperationQueue.main) { [weak self] (notification) in
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
