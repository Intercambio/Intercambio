//
//  NavigationControllerModule.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 02.08.16.
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

@objc public protocol NavigationControllerRouter {
    func presentAccountUserInterface(for accountURI: URL)
}

public class NavigationControllerModule: NSObject {
    
    public let service: CommunicationService
    public weak var router: NavigationControllerRouter?
    
    public init(service: CommunicationService) {
        self.service = service
    }
    
    public func makeNavigationController() -> NavigationController {
        let controller = NavigationController(service: service)
        controller.router = router
        return controller
    }
    
    public func makeNavigationController(rootViewController: UIViewController) -> NavigationController {
        let controller = NavigationController(service: service)
        controller.router = router
        controller.viewControllers = [rootViewController]
        return controller
    }
}

public extension NavigationController {
    
    public convenience init(service: CommunicationService) {
        self.init(navigationBarClass: NavigationBar.self, toolbarClass: nil)
        let presenter = NavigationControllerPresenter(accountManager: service.accountManager)
        presenter.view = self
        self.presenter = presenter
    }
    
    public weak var router: NavigationControllerRouter? {
        set {
            if let presenter = self.presenter as? NavigationControllerPresenter {
                presenter.router = newValue
            }
        }
        get {
            if let presenter = self.presenter as? NavigationControllerPresenter {
                return presenter.router
            } else {
                return nil
            }
        }
    }
}
