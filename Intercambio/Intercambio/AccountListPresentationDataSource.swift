//
//  AccountListPresentationDataSource.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 29.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation
import Fountain
import IntercambioCore

class AccountListPresentationDataSource: NSObject, FTDataSource {

    class Item: AccountListPresentationModel {
        
        var identifier: String {
            return item.jid.stringValue
        }
        
        var accountURI: URL? {
            var components = URLComponents()
            components.scheme = "xmpp"
            components.host = item.jid.host
            components.user = item.jid.user
            return components.url
        }
        
        var name: String? {
            return identifier
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
        self.backingStore = FTMutableSet(sortDescriptors: [SortDescriptor(key: "identifier", ascending: true)])
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
            let items = try keyChain.fetch()
            backingStore.performBatchUpdate({
                self.backingStore.removeAllObjects()
                self.backingStore.addObjects(from: items)
            })
        } catch {
            
        }
    }
    
    // FTDataSource
    
    func numberOfSections() -> UInt {
        return backingStore.numberOfSections()
    }
    
    func numberOfItems(inSection section: UInt) -> UInt {
        return backingStore.numberOfItems(inSection: section)
    }
    
    func sectionItem(forSection section: UInt) -> AnyObject! {
        return nil
    }
    
    func item(at indexPath: IndexPath!) -> AnyObject! {
        if let item = backingStore.item(at: indexPath) as? KeyChainItem {
            return Item(item)
        } else {
            return nil
        }
    }
    
    func observers() -> [AnyObject]! {
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
        
        notificationObservers.append(center.addObserver(forName: NSNotification.Name(rawValue: KeyChainDidClearNotification),
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
