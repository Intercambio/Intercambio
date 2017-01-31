//
//  AccountProfileInteractor.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 04.11.16.
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
