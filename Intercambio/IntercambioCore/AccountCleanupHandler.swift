//
//  AccountCleanupHandler.swift
//  IntercambioCore
//
//  Created by Tobias Kräntzer on 30.01.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import Foundation
import KeyChain
import XMPPFoundation
import XMPPMessageHub
import XMPPContactHub

class AccountCleanupHandler {
    
    let keyChain: KeyChain
    let messageHub: MessageHub
    let contactHub: ContactHub
    
    init(keyChain: KeyChain, messageHub: MessageHub, contactHub: ContactHub) {
        self.keyChain = keyChain
        self.messageHub = messageHub
        self.contactHub = contactHub
        
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(keyChainDidRemoveItem(notification:)),
                           name: Notification.Name(KeyChainDidRemoveItemNotification),
                           object: keyChain)
    }
    
    @objc private func keyChainDidRemoveItem(notification: Notification) {
        guard
            let item = notification.userInfo?[KeyChainItemKey] as? KeyChainItem,
            let account = JID(item.identifier)
            else {
                return
        }
        
        messageHub.deleteResources(for: account) { (error) in
            if error == nil {
                NSLog("Did delete persistent resources of the message hub for account '\(account)'.")
            } else {
                NSLog("Failed to delete persistent resources of the message hub for account '\(account)': \(error)")
            }
        }
        
        contactHub.deleteResources(for: account) { (error) in
            if error == nil {
                NSLog("Did delete persistent resources of the contact hub for account '\(account)'.")
            } else {
                NSLog("Failed to delete persistent resources of the contact hub for account '\(account)': \(error)")
            }
        }
    }
}
