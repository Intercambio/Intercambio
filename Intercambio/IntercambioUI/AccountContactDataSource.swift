//
//  AccountContactDataSource.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 31.01.17.
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
