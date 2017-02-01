//
//  AccountManagerUpdater.swift
//  IntercambioCore
//
//  Created by Tobias Kraentzer on 17.01.17.
//  Copyright © 2017 Tobias Kräntzer.
//
//  This file is part of IntercambioCore.
//
//  IntercambioCore is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option)
//  any later version.
//
//  IntercambioCore is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
//  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along with
//  IntercambioCore. If not, see <http://www.gnu.org/licenses/>.
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
import KeyChain
import CoreXMPP

class AccountManagerUpdater {
    
    let keyChain: KeyChain
    let accountManager: AccountManager
    
    init(accountManager: AccountManager, keyChain: KeyChain) {
        self.accountManager = accountManager
        self.keyChain = keyChain
        
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(keyChainDidAddItem(notification:)),
                           name: Notification.Name(KeyChainDidAddItemNotification),
                           object: keyChain)
        center.addObserver(self,
                           selector: #selector(keyChainDidUpdateItem(notification:)),
                           name: Notification.Name(KeyChainDidUpdateItemNotification),
                           object: keyChain)
        center.addObserver(self,
                           selector: #selector(keyChainDidRemoveItem(notification:)),
                           name: Notification.Name(KeyChainDidRemoveItemNotification),
                           object: keyChain)
        center.addObserver(self,
                           selector: #selector(keyChainDidRemoveAllItems(notification:)),
                           name: Notification.Name(KeyChainDidRemoveAllItemsNotification),
                           object: keyChain)
    }
    
    deinit {
        let center = NotificationCenter.default
        center.removeObserver(self)
    }
    
    func start() {
        do {
            for item in try keyChain.items() {
                if let account = JID(item.identifier) {
                    try accountManager.addAccount(account, options: item.options as? [String : Any] ?? [:])
                }
            }
        } catch {
            NSLog("Failed to add accounts: \(error)")
        }
    }
    
    @objc private func keyChainDidAddItem(notification: Notification) {
        guard
            let item = notification.userInfo?[KeyChainItemKey] as? KeyChainItem,
            let account = JID(item.identifier)
            else {
                return
        }
        
        do {
            try accountManager.addAccount(account, options: item.options as? [String : Any] ?? [:])
            accountManager.connect(account)
        } catch {
            NSLog("Failed to add account '\(account)': \(error)")
        }
    }
    
    @objc private func keyChainDidUpdateItem(notification: Notification) {
        guard
            let item = notification.userInfo?[KeyChainItemKey] as? KeyChainItem,
            let account = JID(item.identifier)
            else {
                return
        }
        accountManager.updateAccount(account, withOptions: item.options as? [String : Any] ?? [:])
    }
    
    @objc private func keyChainDidRemoveItem(notification: Notification) {
        guard
            let item = notification.userInfo?[KeyChainItemKey] as? KeyChainItem,
            let account = JID(item.identifier)
            else {
                return
        }
        accountManager.removeAccount(account)
    }
    
    @objc private func keyChainDidRemoveAllItems(notification: Notification) {
        for account in accountManager.accounts {
            accountManager.removeAccount(account)
        }
    }
}
