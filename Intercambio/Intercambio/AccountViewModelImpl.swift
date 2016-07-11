//
//  AccountModuleAccountViewModel.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 01.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation
import IntercambioCore
import CoreXMPP

class AccountViewModelImpl : AccountViewModel {
    
    let keyChainItem: KeyChainItem
    let info: AccountInfo?
    
    convenience init(keyChainItem: KeyChainItem) {
        self.init(keyChainItem: keyChainItem, info: nil)
    }
    
    init(keyChainItem: KeyChainItem, info: AccountInfo?) {
        self.keyChainItem = keyChainItem
        self.info = info
    }
    
    var identifier: String {
        get { return keyChainItem.identifier }
    }
    
    var enabled: Bool {
        get { return keyChainItem.invisible }
    }
    
    var state: AccountConnectionState {
        get {
            if let i = info {
                return i.connectionState
            } else {
                return.disconnected
            }
        }
    }
    
    var name: String? {
        get { return keyChainItem.identifier }
    }
    
    var options: Dictionary<NSObject, AnyObject> {
        get { return keyChainItem.options }
    }
    
    var error: NSError? {
        get { return info?.recentError }
    }
    
    var nextConnectionAttempt: Date? {
        get { return info?.nextConnectionAttempt }
    }
}

class AccountViewModelEmptyImpl : AccountViewModel {
    let identifier = "undefined"
    let enabled: Bool = false
    let state = AccountConnectionState.disconnected
    let name: String? = nil
    let options: Dictionary<NSObject, AnyObject> = [:]
    let error: NSError? = nil
    let nextConnectionAttempt: Date? = nil
}
