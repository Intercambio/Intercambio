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
    
    private let service: CommunicationService
    weak private var router: AccountListRouter?
    
    public init(service: CommunicationService, router: AccountListRouter) {
        self.service = service
        self.router = router
    }
    
    public func viewController() -> (UIViewController?) {
        
        let presenter = AccountListPresenter(keyChain: service.keyChain, router: router!)
        let viewController = AccountListViewController()
        
        viewController.eventHandler = presenter
        presenter.view = viewController
        
        return viewController
    }
}
