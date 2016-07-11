//
//  AccountModule.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 01.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import IntercambioCore

public class AccountModule : NSObject {
    
    private let service: CommunicationService
    private let router: AccountModuleRouter
    
    init(service: CommunicationService, router: AccountModuleRouter) {
        self.service = service
        self.router = router
    }
    
    public func viewController(uri: URL) -> (UIViewController?) {
        
        if let host = uri.host,
            let jid = JID(user: uri.user, host: host, resource: nil) {
            
            let interactor = AccountModuleInteractorImpl(accountJID: jid,
                                                         keyChain: service.keyChain,
                                                         accountManager: service.accountManager)
            
            let presenter = AccountModulePresenterImpl()
            let viewControler = AccountModuleViewController()
            
            // strong references (view controller -> presenter -> interactor)
            viewControler.eventHandler = presenter
            presenter.interactor = interactor
            
            // weak references
            interactor.presenter = presenter
            presenter.userInterface = viewControler
            presenter.router = router
            
            return viewControler
        } else {
            return nil
        }
    }
}
