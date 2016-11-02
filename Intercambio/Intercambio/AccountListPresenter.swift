//
//  AccountListPresenter.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 18.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation
import IntercambioCore

class AccountListPresenter : AccountListViewEventHandler {
    
    let keyChain: KeyChain
    let router: AccountListRouter?
    let dataSource: AccountListDataSource
    
    weak var view: AccountListView? {
        didSet {
            view?.dataSource = dataSource
        }
    }
    
    init(keyChain: KeyChain, router: AccountListRouter) {
        self.keyChain = keyChain
        self.router = router
        self.dataSource = AccountListDataSource(keyChain: self.keyChain)
    }
    
    // AccountListViewEventHandler
    
    func addAccount() {
        router?.presentNewAccountUserInterface()
    }
    
    func view(_ view: AccountListView, didSelectItemAt indexPath: IndexPath) {
        if let uri = dataSource.accountURI(forItemAt: indexPath) {
            router?.presentAccountUserInterface(for: uri)
        }
    }
}
