//
//  SettingsDataSource.swift
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
import Fountain
import KeyChain
import XMPPFoundation
import CoreXMPP

let SettingsDataSourceAccountKey: String = "SettingsDataSourceAccountKey"
let SettingsDataSourceRemoveActionKey: String = "SettingsDataSourceRemoveActionKey"

protocol SettingsDataSourceDelegate: class {
    func settingsDataSource(_ dataSource: SettingsDataSource, didRemoveAccount jid: JID) -> Void
}

class SettingsDataSource: NSObject, FTDataSource {
    
    let accountJID: JID
    let keyChain: KeyChain
    weak var delegate: SettingsDataSourceDelegate?
    
    private let proxy: FTObserverProxy
    
    private var item: KeyChainItem?
    private var options: [AnyHashable: Any] = [:]
    
    init(accountJID: JID, keyChain: KeyChain) {
        self.accountJID = accountJID
        self.keyChain = keyChain
        proxy = FTObserverProxy()
        super.init()
        proxy.object = self
    }
    
    // KVO
    
    override func value(forKey key: String) -> Any? {
        if supportedKeys.contains(key) {
            return options[key]
        } else {
            return super.value(forKey: key)
        }
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        if supportedKeys.contains(key) {
            if let indexPath = self.indexPath(for: key) {
                proxy.dataSourceDidChange(self)
                options[key] = value
                proxy.dataSource(self, didChangeItemsAtIndexPaths: [indexPath])
                proxy.dataSourceDidChange(self)
            } else {
                options[key] = value
            }
        } else {
            super.setValue(value, forKey: key)
        }
    }
    
    // Options
    
    var supportedKeys: [String] {
        return [ClientOptionsResourceKey, WebsocketStreamURLKey]
    }
    
    private func indexPath(for option: String) -> IndexPath? {
        if option == SettingsDataSourceAccountKey {
            return IndexPath(item: 0, section: 0)
        } else if option == ClientOptionsResourceKey {
            return IndexPath(item: 1, section: 0)
        } else if option == WebsocketStreamURLKey {
            return IndexPath(item: 0, section: 1)
        } else if option == SettingsDataSourceRemoveActionKey {
            return IndexPath(item: 0, section: 2)
        } else {
            return nil
        }
    }
    
    private func option(for indexPath: IndexPath) -> String? {
        switch indexPath.section {
            
        case 0:
            switch indexPath.item {
            case 0: return SettingsDataSourceAccountKey
            case 1: return ClientOptionsResourceKey
            default: return nil
            }
            
        case 1:
            switch indexPath.item {
            case 0: return WebsocketStreamURLKey
            default: return nil
            }
            
        case 2:
            switch indexPath.item {
            case 0: return SettingsDataSourceRemoveActionKey
            default: return nil
            }
            
        default:
            return nil
        }
    }
    
    // Reload
    
    func reload() throws {
        let item = try keyChain.item(with: accountJID.stringValue)
        
        proxy.dataSourceWillReset(self)
        self.item = item
        options = self.item?.options ?? [:]
        proxy.dataSourceDidReset(self)
    }
    
    // Save
    
    func save() throws {
        if let item = self.item {
            var newOptions: [AnyHashable: Any] = [:]
            for (key, value) in options {
                if let k = key as? String,
                    supportedKeys.contains(k) {
                    newOptions[key] = value
                }
            }
            let newItem = KeyChainItem(
                identifier: item.identifier,
                invisible: item.invisible,
                options: newOptions
            )
            try keyChain.update(newItem)
        }
    }
    
    // Update
    
    func setValue(_ value: Any?, forItemAt indexPath: IndexPath) {
        if let key = option(for: indexPath) {
            setValue(value, forKey: key)
        }
    }
    
    // Action
    
    func performAction(_ action: Selector, forItemAt _: IndexPath) {
        if action == #selector(removeAccount) {
            do {
                try removeAccount()
            } catch {
                
            }
        }
    }
    
    // Remove
    
    func removeAccount() throws {
        if let item = self.item,
            let account = JID(item.identifier) {
            try keyChain.remove(item)
            delegate?.settingsDataSource(self, didRemoveAccount: account)
        }
    }
    
    // FTDataSource
    
    func numberOfSections() -> UInt {
        if item != nil {
            return 3
        } else {
            return 0
        }
    }
    
    func numberOfItems(inSection section: UInt) -> UInt {
        switch section {
        case 0: return 2
        case 1: return 1
        case 2: return 1
        default: return 0
        }
    }
    
    func sectionItem(forSection section: UInt) -> Any! {
        switch section {
        case 0:
            let item = FormSectionData()
            item.title = "Account"
            return item
            
        case 1:
            let item = FormSectionData()
            item.title = "Websocket URL"
            item.instructions = "Websocket URL that should be used."
            return item
            
        case 2:
            let item = FormSectionData()
            item.title = nil
            item.instructions = "Removing the account will also delete all messages from this device. This will not delete the account on the server."
            return item
            
        default:
            return nil
        }
    }
    
    func item(at indexPath: IndexPath!) -> Any! {
        if let key = option(for: indexPath) {
            if key == SettingsDataSourceAccountKey {
                let item = FormValueItemData(identifier: key)
                item.title = accountJID.stringValue
                item.hasDetails = false
                return item
            } else if key == ClientOptionsResourceKey {
                let item = FormTextItemData(identifier: key)
                item.placeholder = "Resource Name"
                item.text = value(forKey: key) as? String
                return item
            } else if key == WebsocketStreamURLKey {
                let item = FormURLItemData(identifier: key)
                item.placeholder = "Automatic Discovery"
                item.url = value(forKey: key) as? URL
                return item
            } else if key == SettingsDataSourceRemoveActionKey {
                let item = FormButtonItemData(identifier: key, action: #selector(removeAccount))
                item.title = "Remove Account"
                item.enabled = true
                item.destructive = true
                item.destructionMessage = "Are you sure, that you want to remove '\(accountJID.stringValue)' from this device?"
                return item
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func observers() -> [Any]! {
        return proxy.observers()
    }
    
    func addObserver(_ observer: FTDataSourceObserver!) {
        proxy.addObserver(observer)
    }
    
    func removeObserver(_ observer: FTDataSourceObserver!) {
        proxy.removeObserver(observer)
    }
}
