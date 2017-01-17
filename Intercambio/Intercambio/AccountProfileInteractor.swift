//
//  AccountProfileInteractor.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 04.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation
import IntercambioCore
import KeyChain
import CoreXMPP

class AccountProfileInteractor : AccountProfileProvider {
    
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
    
    // AccountProfileProvider

    var accountURI: URL? {
        var components = URLComponents()
        components.scheme = "xmpp"
        components.host = accountJID.host
        components.user = accountJID.user
        return components.url
    }
    
    var account: AccountProfileModel? {
        get {
            do {
                let item = try keyChain.item(with: accountJID.stringValue)
                let info = accountManager.info(for: accountJID)
                return Model(keyChainItem: item, info: info)
            } catch {
                return nil
            }
        }
    }
    
    func connect() throws {
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
        
        notificationObservers.append(center.addObserver(forName: NSNotification.Name(rawValue: KeyChainDidRemoveAllItemsNotification),
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
            let item = userInfo[KeyChainItemKey] as? KeyChainItem,
            let account = JID(item.identifier) {
            if account == accountJID {
                self.handleAccountUpdate()
            }
        }
    }
    
    private func forwardAccountManagerDidChangeAccountNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo,
            let jid = userInfo[AccountManagerAccountJIDKey] as? JID {
            if jid == accountJID {
                self.handleAccountUpdate()
            }
        }
    }
    
    private func handleAccountUpdate() {
        let center = NotificationCenter.default
        center.post(name: AccountProfileProviderDidUpdateAccount, object: self)
    }
}

extension AccountProfileInteractor {
    class Model: AccountProfileModel {
        
        let keyChainItem: KeyChainItem
        let info: AccountInfo?
        
        convenience init(keyChainItem: KeyChainItem) {
            self.init(keyChainItem: keyChainItem, info: nil)
        }
        
        init(keyChainItem: KeyChainItem, info: AccountInfo?) {
            self.keyChainItem = keyChainItem
            self.info = info
        }
        
        var enabled: Bool {
            get { return keyChainItem.invisible == false }
        }
        
        var state: AccountProfilePresentationModelConnectionState {
            get {
                if let i = info {
                    return i.connectionState
                } else {
                    return .disconnected
                }
            }
        }
        
        var name: String? {
            get { return keyChainItem.identifier }
        }
        
        var error: Error? {
            get { return info?.recentError }
        }
        
        var nextConnectionAttempt: Date? {
            get { return info?.nextConnectionAttempt }
        }
    }
}
