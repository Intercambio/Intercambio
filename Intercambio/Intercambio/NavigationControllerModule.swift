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
    
    private let service: CommunicationService
    weak private var router: NavigationControllerRouter?
    
    public init(service: CommunicationService, router: NavigationControllerRouter) {
        self.service = service
        self.router = router
    }
    
    public func navigationController() -> (UINavigationController) {
        let view = NavigationController(navigationBarClass: NavigationBar.self, toolbarClass: nil)
        let presenter = NavigationControllerPresenter(accountManager: service.accountManager)
        presenter.view = view
        presenter.router = router
        view.presenter = presenter
        return view
    }
    
    public func navigationController(rootViewController: UIViewController) -> (UINavigationController) {
        let controller = navigationController()
        controller.viewControllers = [rootViewController]
        return controller
    }
}
