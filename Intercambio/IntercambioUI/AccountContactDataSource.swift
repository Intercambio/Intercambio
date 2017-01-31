//
//  AccountContactDataSource.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 31.01.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import Foundation
import Fountain
import XMPPContactHub

class AccountContactDataSource: NSObject, FTDataSource {
    
    private let roster: Roster
    private let backingStore: FTMutableSet
    private let proxy: FTObserverProxy
    
    init(roster: Roster) {
        
        let sortDescriptor = NSSortDescriptor(key: "self", ascending: true) { (lhs, rhs) -> ComparisonResult in
            guard
                let lhs = lhs as? Item,
                let rhs = rhs as? Item
                else { return .orderedSame }
            
            let lhsString = (lhs.name ?? lhs.counterpart.stringValue).lowercased()
            let rhsString = (rhs.name ?? rhs.counterpart.stringValue).lowercased()
            
            if lhsString == rhsString {
                return .orderedSame
            } else if lhsString < rhsString {
                return .orderedAscending
            } else {
                return .orderedDescending
            }
        }
        
        self.roster = roster
        self.proxy = FTObserverProxy()
        self.backingStore = FTMutableSet(sortDescriptors: [sortDescriptor])
        
        super.init()
        
        proxy.object = self
        backingStore.addObserver(proxy)
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(rosterDidChange(_:)), name: Notification.Name.RosterDidChange, object: roster)
        
        loadItems()
    }
    
    deinit {
        let center = NotificationCenter.default
        center.removeObserver(self)
    }
    
    private func loadItems() {
        do {
            let items = try roster.items()
            backingStore.performBatchUpdate({
                self.backingStore.removeAllObjects()
                self.backingStore.addObjects(from: items)
            })
        } catch {
            NSLog("Failed to get items for the roster: \(error)")
        }
    }
    
    @objc private func rosterDidChange(_ notification: Notification) {
        DispatchQueue.main.async {
            self.loadItems()
        }
    }
    
    // MARK: - FTDataSource
    
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
        if let item = backingStore.item(at: indexPath) as? Item {
            return ViewModel(item: item)
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
    
    class ViewModel: AccountContactViewModel {
        
        let item: Item
        init(item: Item) {
            self.item = item
        }
        
        var name: String {
            return item.name ?? item.counterpart.stringValue
        }
    }
}
