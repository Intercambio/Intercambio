//
//  NavigationControllerModule.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 02.08.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import IntercambioCore

@objc public protocol NavigationControllerRouter {
    func presentAccountUserInterface(for accountURI: URL)
}

public class NavigationControllerModule : NSObject {
    
    public let service: CommunicationService
    weak public var router: NavigationControllerRouter?
    
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
    
    weak public var router: NavigationControllerRouter? {
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
