//
//  SettingsDataSource.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 04.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation
import Fountain
import IntercambioCore
import CoreXMPP

let SettingsDataSourceAccountKey: String = "SettingsDataSourceAccountKey"

class SettingsDataSource: NSObject, FTDataSource {

    let accountJID: JID
    let keyChain: KeyChain
    
    private let proxy: FTObserverProxy
    
    private var item: KeyChainItem?
    private var options: [AnyHashable : Any] = [:]
    
    init(accountJID: JID, keyChain: KeyChain) {
        self.accountJID = accountJID
        self.keyChain = keyChain
        proxy = FTObserverProxy()
        super.init()
        proxy.object = self
    }
    
    // KVO
    
    override func value(forKey key: String) -> Any? {
        if supportedKeys.contains(key)  {
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
        return [WebsocketStreamURLKey]
    }
    
    private func indexPath(for option: String) -> IndexPath? {
        if option == SettingsDataSourceAccountKey {
            return IndexPath(item: 0, section: 0)
        } else if option == WebsocketStreamURLKey {
            return IndexPath(item: 0, section: 1)
        } else {
            return nil
        }
    }
    
    private func option(for indexPath: IndexPath) -> String? {
        switch indexPath.section {

        case 0:
            switch indexPath.item {
            case 0:
                return SettingsDataSourceAccountKey
            default:
                return nil
            }
            
        case 1:
            switch indexPath.item {
            case 0:
                return WebsocketStreamURLKey
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    // Reload
    
    func reload() throws {
        let item = try keyChain.item(jid: accountJID)
        
        proxy.dataSourceWillReset(self)
        self.item = item
        options = self.item?.options ?? [:]
        proxy.dataSourceDidReset(self)
    }
    
    // Save
    
    func save() throws {
        if let item = self.item {
            var newOptions: [AnyHashable : Any] = [:]
            for (key, value) in options {
                if let k = key as? String,
                    supportedKeys.contains(k) {
                    newOptions[key] = value
                }
            }
            let newItem = KeyChainItem(jid: item.jid,
                                       invisible: item.invisible,
                                       options: newOptions)
            try keyChain.update(newItem)
        }
    }
    
    // Update
    
    func setValue(_ value: Any?, forItemAt indexPath: IndexPath) {
        if let key = option(for: indexPath) {
            setValue(value, forKey: key)
        }
    }
    
    // FTDataSource
    
    func numberOfSections() -> UInt {
        if item != nil {
            return 2
        } else {
            return 0
        }
    }
    
    func numberOfItems(inSection section: UInt) -> UInt {
        switch section {
        case 0: return 1
        case 1: return 1
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
            } else if key == WebsocketStreamURLKey {
                let item = FormURLItemData(identifier: key)
                item.placeholder = "Automatic Discovery"
                item.url = value(forKey: key) as? URL
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
