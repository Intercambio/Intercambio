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
}

public class AccountModule : NSObject {
    
    public let service: CommunicationService
    weak public var router: AccountRouter?
    
    public init(service: CommunicationService) {
        self.service = service
    }
    
    public var accountProfileModule: AccountProfileModule?
    
    public func makeAccountViewController(uri: URL) -> AccountViewController {
        let controller = AccountViewController()
        controller.accountProfileViewController = accountProfileModule?.makeAccountProfileViewController(uri: uri)
        return controller
    }
}

public extension AccountViewController {
    public convenience init?(service: CommunicationService, account uri: URL) {
        self.init()

        let presenter = AccountPresenter()
        presenter.view = self
        self.presenter = presenter

    }
    
    public var router: AccountRouter? {
        set {
            if let presenter = self.presenter as? AccountPresenter {
                presenter.router = newValue
            }
        }
        get {
            if let presenter = self.presenter as? AccountPresenter {
                return presenter.router
            } else {
                return nil
            }
        }
    }
}
