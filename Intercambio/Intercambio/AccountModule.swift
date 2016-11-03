//
//  AccountModule.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 01.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import IntercambioCore

@objc public protocol AccountRouter : class {
    func presentSettingsUserInterface(for accountURI: URL)
}

public class AccountModule : NSObject {
    
    public let service: CommunicationService
    weak public var router: AccountRouter?
    
    public init(service: CommunicationService) {
        self.service = service
    }
    
    public func viewController(uri: URL) -> AccountViewController? {
        
        if let host = uri.host,
            let jid = JID(user: uri.user, host: host, resource: nil) {
            
            let interactor = AccountInteractor(accountJID: jid, keyChain: service.keyChain, accountManager: service.accountManager)
            let presenter = AccountPresenter()
            let viewControler = AccountViewController()
            
            // strong references (view controller -> presenter -> interactor)
            viewControler.eventHandler = presenter
            presenter.interactor = interactor
            
            // weak references
            interactor.output = presenter
            presenter.view = viewControler
            presenter.router = router
            
            return viewControler
        } else {
            return nil
        }
    }
}
