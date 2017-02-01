//
//  AccountModule.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 01.07.16.
//  Copyright © 2016, 2017 Tobias Kräntzer.
//
//  This file is part of Intercambio.
//
//  Intercambio is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option)
//  any later version.
//
//  Intercambio is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
//  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along with
//  Intercambio. If not, see <http://www.gnu.org/licenses/>.
//
//  Linking this library statically or dynamically with other modules is making
//  a combined work based on this library. Thus, the terms and conditions of the
//  GNU General Public License cover the whole combination.
//
//  As a special exception, the copyright holders of this library give you
//  permission to link this library with independent modules to produce an
//  executable, regardless of the license terms of these independent modules,
//  and to copy and distribute the resulting executable under terms of your
//  choice, provided that you also meet, for each linked independent module, the
//  terms and conditions of the license of that module. An independent module is
//  a module which is not derived from or based on this library. If you modify
//  this library, you must extend this exception to your version of the library.
//

import UIKit
import IntercambioCore

@objc public protocol AccountRouter: class {
    func presentNewAccountUserInterface()
}

public class AccountModule: NSObject {
    
    public let service: CommunicationService
    public weak var router: AccountRouter?
    
    public init(service: CommunicationService) {
        self.service = service
    }
    
    public var accountProfileModule: AccountProfileModule?
    
    public func makeAccountViewController(uri: URL) -> AccountViewController {
        let controller = AccountViewController(service: service, account: uri)
        controller.accountProfileViewController = accountProfileModule?.makeAccountProfileViewController(uri: uri)
        controller.router = router
        return controller
    }
}

public extension AccountViewController {
    public convenience init(service: CommunicationService, account uri: URL) {
        self.init()
        
        let presenter = AccountPresenter(accountURI: uri, contactHub: service.contactHub)
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
    
    public var account: URL? {
        guard let presenter = self.presenter as? AccountPresenter else {
            return nil
        }
        return presenter.accountURI
    }
}
