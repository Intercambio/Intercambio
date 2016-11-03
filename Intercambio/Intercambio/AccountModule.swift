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
    
    public func makeAccountViewController(uri: URL) -> AccountViewController? {
        if let controller = AccountViewController(service: service, account: uri) {
            controller.router = router
            return controller
        } else {
            return nil
        }
    }
}

public extension AccountViewController {
    public convenience init?(service: CommunicationService, account uri: URL) {
        if let host = uri.host, let jid = JID(user: uri.user, host: host, resource: nil) {
            self.init()
            
            let interactor = AccountInteractor(accountJID: jid, keyChain: service.keyChain, accountManager: service.accountManager)
            let presenter = AccountPresenter()
            
            // strong references (view controller -> presenter -> interactor)
            self.eventHandler = presenter
            presenter.interactor = interactor
            
            // weak references
            interactor.output = presenter
            presenter.view = self
        } else {
            return nil
        }
    }
    
    public var router: AccountRouter? {
        set {
            if let presenter = self.eventHandler as? AccountPresenter {
                presenter.router = newValue
            }
        }
        get {
            if let presenter = self.eventHandler as? AccountPresenter {
                return presenter.router
            } else {
                return nil
            }
        }
    }
}
