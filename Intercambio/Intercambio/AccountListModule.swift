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
    
    public func viewController() -> AccountListViewController {
        
        let presenter = AccountListPresenter(keyChain: service.keyChain, router: router!)
        let viewController = AccountListViewController()
        
        viewController.presenter = presenter
        presenter.view = viewController
        
        return viewController
    }
}
