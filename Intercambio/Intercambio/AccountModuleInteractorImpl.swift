//
//  AccountModuleInteractorImpl.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 01.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation
import IntercambioCore
import CoreXMPP

public class AccountModuleInteractorImpl : AccountModuleInteractor {

    private let accountJID: JID
    private let keyChain: KeyChain
    private let accountManager: AccountManager
    
    init(accountJID: JID, keyChain: KeyChain, accountManager: AccountManager) {
        self.accountJID = accountJID
        self.keyChain = keyChain
        self.accountManager = accountManager
        registerNotificationObservers()
    }
    
    deinit {
        unregisterNotificationObservers()
    }
    
    public var account: AccountViewModel? {
        get {
            do {
                let item = try keyChain.item(jid: accountJID)
                let info = accountManager.info(for: accountJID)
                return AccountViewModelImpl(keyChainItem: item, info:  info)
            } catch {
                return nil
            }
        }
    }
    
    public func enable() throws {
        var item = try keyChain.item(jid: accountJID)
        if item.invisible == true {
            item = KeyChainItem(jid: item.jid, invisible: false, options: item.options)
            try keyChain.update(item)
        }
    }
    
    public func disable() throws {
        var item = try keyChain.item(jid: accountJID)
        if item.invisible == false {
            item = KeyChainItem(jid: item.jid, invisible: true, options: item.options)
            try keyChain.update(item)
        }
    }
    
    public func update(options: Dictionary<String, AnyObject>) throws
    {
        var item = try keyChain.item(jid : accountJID)
        item = KeyChainItem(jid: item.jid, invisible: item.invisible, options: options)
        try keyChain.update(item)
    }
    
    public func connect() throws {
        accountManager.connect(accountJID)
    }
    
    // Notification Handling
    
    private lazy var notificationObservers = [NSObjectProtocol]()
    
    private func registerNotificationObservers() {
        let center = NotificationCenter.default
        
        notificationObservers.append(center.addObserver(forName: NSNotification.Name(rawValue: KeyChainDidAddItemNotification),
                                                        object: keyChain,
                                                        queue: OperationQueue.main) { [weak self] (notification) in
                                                            self?.forwardKeyChainNotification(notification) })
        
        notificationObservers.append(center.addObserver(forName: NSNotification.Name(rawValue: KeyChainDidUpdateItemNotification),
                                                        object: keyChain,
                                                        queue: OperationQueue.main) { [weak self] (notification) in
                                                            self?.forwardKeyChainNotification(notification) })
        
        notificationObservers.append(center.addObserver(forName: NSNotification.Name(rawValue: KeyChainDidRemoveItemNotification),
                                                        object: keyChain,
                                                        queue: OperationQueue.main) { [weak self] (notification) in
                                                            self?.forwardKeyChainNotification(notification) })
        
        notificationObservers.append(center.addObserver(forName: NSNotification.Name(rawValue: KeyChainDidClearNotification),
                                                        object: keyChain,
                                                        queue: OperationQueue.main) { [weak self] (notification) in
                                                            self?.forwardKeyChainNotification(notification) })
        
        notificationObservers.append(center.addObserver(forName: NSNotification.Name(rawValue: AccountManagerDidChangeAccount),
                                                        object: accountManager,
                                                        queue: OperationQueue.main) { [weak self] (notification) in
                                                            self?.forwardAccountManagerDidChangeAccountNotification(notification) })
    }
    
    private func unregisterNotificationObservers() {
        let center = NotificationCenter.default
        for observer in notificationObservers {
            center.removeObserver(observer)
        }
        notificationObservers.removeAll()
    }
    
    private func forwardKeyChainNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo,
        let item = userInfo[KeyChainItemKey] as? KeyChainItem {
            if item.jid == accountJID {
                self.postAccountDidChangeNotification()
            }
        }
    }
    
    private func forwardAccountManagerDidChangeAccountNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo,
        let jid = userInfo[AccountManagerAccountJIDKey] as? JID {
            if jid == accountJID {
                self.postAccountDidChangeNotification()
            }
        }
    }

    private func postAccountDidChangeNotification() {
        let center = NotificationCenter.default
        center.post(name: AccountModuleInteractorDidUpdateAccount, object: self)
    }
}
