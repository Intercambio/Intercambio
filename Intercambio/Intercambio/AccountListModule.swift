//
//  AccountListModule.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 18.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import IntercambioCore

@objc public protocol AccountListRouter : class {
    func presentAccountUserInterface(for accountURI: URL)
    func presentNewAccountUserInterface()
}

public class AccountListModule : NSObject {
    
    public let service: CommunicationService
    weak public var router: AccountListRouter?
    
    public init(service: CommunicationService) {
        self.service = service
    }
    
    public func makeAccountListViewController() -> AccountListViewController {
        let controller = AccountListViewController(service: service)
        controller.router = router
        return controller
    }
}

public extension AccountListViewController {
    
    public convenience init(service: CommunicationService) {
        self.init()
        let presenter = AccountListPresenter(keyChain: service.keyChain)
        presenter.view = self
        self.presenter = presenter
    }
    
    weak public var router: AccountListRouter? {
        set {
            if let presenter = self.presenter as? AccountListPresenter {
                presenter.router = newValue
            }
        }
        get {
            if let presenter = self.presenter as? AccountListPresenter {
                return presenter.router
            } else {
                return nil
            }
        }
    }
}
