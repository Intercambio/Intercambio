//
//  AccountProfileModule.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 04.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import IntercambioCore
import XMPPFoundation

@objc public protocol AccountProfileRouter : class {
    func presentSettingsUserInterface(for accountURI: URL)
}

public class AccountProfileModule : NSObject {
    
    public let service: CommunicationService
    weak public var router: AccountProfileRouter?
    
    public init(service: CommunicationService) {
        self.service = service
    }
    
    public func makeAccountProfileViewController(uri: URL) -> AccountProfileViewController? {
        if let controller = AccountProfileViewController(service: service, account: uri) {
            controller.router = router
            return controller
        } else {
            return nil
        }
    }
}

public extension AccountProfileViewController {
    public convenience init?(service: CommunicationService, account uri: URL) {
        if let host = uri.host {
            let jid = JID(user: uri.user, host: host, resource: nil)
            
            self.init()
            
            let presenter = AccountProfilePresenter()
            presenter.view = self
            self.presenter = presenter
            
            let interactor = AccountProfileInteractor(accountJID: jid, keyChain: service.keyChain, accountManager: service.accountManager)
            presenter.interactor = interactor
            
            
        } else {
            return nil
        }
    }
    
    public var router: AccountProfileRouter? {
        set {
            if let presenter = self.presenter as? AccountProfilePresenter {
                presenter.router = newValue
            }
        }
        get {
            if let presenter = self.presenter as? AccountProfilePresenter {
                return presenter.router
            } else {
                return nil
            }
        }
    }
}
