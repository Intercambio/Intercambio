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
    let dataSource: FTDataSource
    
    weak var view: AccountListView? {
        didSet {
            view?.dataSource = dataSource
        }
    }
    
    init(keyChain: KeyChain, router: AccountListRouter) {
        self.keyChain = keyChain
        self.router = router
        self.dataSource = AccountListPresentationDataSource(keyChain: self.keyChain)
    }
    
    // AccountListViewEventHandler
    
    func didTapNewAccount() {
        router?.presentNewAccountUserInterface()
    }
    
    func didSelect(_ account: AccountListPresentationModel) {
        if let accountURI = account.accountURI {
            router?.presentAccountUserInterface(for: accountURI)
        }
    }
}
