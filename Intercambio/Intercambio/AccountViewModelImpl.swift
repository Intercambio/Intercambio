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

class AccountPresentationModelImpl : AccountPresentationModel {
    
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
    
    var accountURI: URL? {
        var components = URLComponents()
        components.scheme = "xmpp"
        components.host = keyChainItem.jid.host
        components.user = keyChainItem.jid.user
        return components.url
    }
    
    var enabled: Bool {
        get { return keyChainItem.invisible == false }
    }
    
    var state: AccountPresentationModelConnectionState {
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

class AccountViewModelEmptyImpl : AccountPresentationModel {
    let identifier = "undefined"
    let accountURI: URL? = nil
    let enabled: Bool = false
    let state = AccountPresentationModelConnectionState.disconnected
    let name: String? = nil
    let options: Dictionary<NSObject, AnyObject> = [:]
    let error: NSError? = nil
    let nextConnectionAttempt: Date? = nil
}
