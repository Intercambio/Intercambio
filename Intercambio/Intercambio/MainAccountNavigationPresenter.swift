//
//  MainAccountNavigationPresenter.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 12.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit


protocol MainAccountNavigationPresenterFactory {
    func makeAccountListViewController() -> AccountListViewController?
    func makeAccountViewController(uri: URL) -> AccountViewController?
}

class MainAccountNavigationPresenter: NSObject {

    weak var view: UINavigationController? {
        didSet {
            setupView()
        }
    }
    
    let factory: MainAccountNavigationPresenterFactory
    init(factory: MainAccountNavigationPresenterFactory) {
        self.factory = factory
        super.init()
    }
    
    // MARK: Setup
    
    private func setupView() {
        
        guard let view = self.view else { return }

        view.delegate = self
        
        if let viewController = factory.makeAccountListViewController() {
            view.setViewControllers([viewController], animated: false)
        }
    }
    
    // MARK: Show
    
    func showAccount(for uri: URL, animated: Bool = true) {
        
        guard let navigationController = view else { return }
        guard let viewController = factory.makeAccountViewController(uri: uri) else { return }

        var animated = animated
        if navigationController.viewControllers.count > 1 {
            animated = false
            navigationController.popToRootViewController(animated: animated)
        }

        navigationController.pushViewController(viewController, animated: animated)
    }
}

extension MainAccountNavigationPresenter: UINavigationControllerDelegate {
    
}
