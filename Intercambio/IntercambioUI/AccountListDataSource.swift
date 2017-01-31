//
//  AccountListDataSource.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 29.07.16.
//  Copyright © 2016 Tobias Kräntzer. //
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
import IntercambioCore

class AccountListDataSource: NSObject, FTDataSource {

    class Model: AccountListViewModel {
        
        var name: String {
            return item.identifier
        }
        
        private let item: KeyChainItem
        
        init(_ item: KeyChainItem) {
            self.item = item
        }
    }
    
    private let backingStore :FTMutableSet
    private let proxy: FTObserverProxy
    private let keyChain: KeyChain
    
    init(keyChain: KeyChain) {
        self.keyChain = keyChain
        self.proxy = FTObserverProxy()
        self.backingStore = FTMutableSet(sortDescriptors: [NSSortDescriptor(key: "identifier", ascending: true)])
        super.init()
        
        proxy.object = self
        backingStore.addObserver(proxy)
        registerNotificationObservers()
        loadItems()
    }
    
    deinit {
        unregisterNotificationObservers()
    }
    
    private func loadItems() {
        do {
            let items = try keyChain.items()
            backingStore.performBatchUpdate({
                self.backingStore.removeAllObjects()
                self.backingStore.addObjects(from: items)
            })
        } catch {
            
        }
    }
    
    func accountURI(forItemAt indexPath: IndexPath) -> URL? {
        if let item = backingStore.item(at: indexPath) as? KeyChainItem,
            let account = JID(item.identifier) {
            var components = URLComponents()
            components.scheme = "xmpp"
            components.host = account.host
            components.user = account.user
            return components.url
        } else {
            return nil
        }
    }
    
    // FTDataSource
    
    func numberOfSections() -> UInt {
        return backingStore.numberOfSections()
    }
    
    func numberOfItems(inSection section: UInt) -> UInt {
        return backingStore.numberOfItems(inSection: section)
    }
    
    func sectionItem(forSection section: UInt) -> Any! {
        return nil
    }
    
    func item(at indexPath: IndexPath!) -> Any! {
        if let item = backingStore.item(at: indexPath) as? KeyChainItem {
            return Model(item)
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
    
    // Notification Handling
    
    private lazy var notificationObservers = [NSObjectProtocol]()
    
    private func registerNotificationObservers() {
        let center = NotificationCenter.default
        
        notificationObservers.append(center.addObserver(forName: NSNotification.Name(rawValue: KeyChainDidAddItemNotification),
                                                        object: keyChain,
                                                        queue: OperationQueue.main) { [weak self] (notification) in
                                                            if let dataSource = self?.backingStore,
                                                                let item = notification.userInfo?[KeyChainItemKey] as? KeyChainItem {
                                                                dataSource.add(item)
                                                            }
            })
        
        notificationObservers.append(center.addObserver(forName: NSNotification.Name(rawValue: KeyChainDidUpdateItemNotification),
                                                        object: keyChain,
                                                        queue: OperationQueue.main) { [weak self] (notification) in
                                                            if let dataSource = self?.backingStore,
                                                                let item = notification.userInfo?[KeyChainItemKey] as? KeyChainItem {
                                                                dataSource.add(item)
                                                            }
            })
        
        notificationObservers.append(center.addObserver(forName: NSNotification.Name(rawValue: KeyChainDidRemoveItemNotification),
                                                        object: keyChain,
                                                        queue: OperationQueue.main) { [weak self] (notification) in
                                                            if let dataSource = self?.backingStore,
                                                                let item = notification.userInfo?[KeyChainItemKey] as? KeyChainItem {
                                                                dataSource.remove(item)
                                                            }
            })
        
        notificationObservers.append(center.addObserver(forName: NSNotification.Name(rawValue: KeyChainDidRemoveAllItemsNotification),
                                                        object: keyChain,
                                                        queue: OperationQueue.main) { [weak self] (notification) in
                                                            if let dataSource = self?.backingStore {
                                                                dataSource.removeAllObjects()
                                                            }
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
