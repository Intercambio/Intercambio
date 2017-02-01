//
//  MainAccountNavigationPresenter.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 12.11.16.
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
import XMPPFoundation
import KeyChain
import IntercambioCore

protocol MainAccountNavigationPresenterFactory {
    func makeAccountListViewController() -> AccountListViewController?
    func makeAccountViewController(uri: URL) -> AccountViewController?
    func makeSignupViewController() -> SignupViewController?
}

class MainAccountNavigationPresenter: NSObject {
    
    weak var view: UINavigationController? {
        didSet {
            setupView()
        }
    }
    
    let keyChain: KeyChain
    let factory: MainAccountNavigationPresenterFactory
    init(keyChain: KeyChain, factory: MainAccountNavigationPresenterFactory) {
        self.keyChain = keyChain
        self.factory = factory
        super.init()
        registerNotificationObservers()
    }
    
    // MARK: Setup
    
    private func setupView(animated: Bool = false) {
        guard let view = self.view else { return }
        view.delegate = self
        view.setViewControllers(viewControllers(for: accounts()), animated: animated)
    }
    
    private func viewControllers(for accounts: [JID]) -> [UIViewController] {
        
        switch accounts.count {
        case 0:
            if let viewController = signupViewController() {
                return [viewController]
            } else if let viewController = factory.makeSignupViewController() {
                return [viewController]
            } else {
                return []
            }
            
        case 1:
            let jid = accounts.first!
            var components = URLComponents()
            components.scheme = "xmpp"
            components.host = jid.host
            components.user = jid.user
            if let uri = components.url {
                if let viewController = accountViewController(for: uri) {
                    return [viewController]
                } else if let viewController = factory.makeAccountViewController(uri: uri) {
                    return [viewController]
                } else {
                    return []
                }
            } else {
                return []
            }
            
        default:
            
            var viewControllers: [UIViewController] = []
            
            if let accountListViewController = accountListViewController() {
                viewControllers.append(accountListViewController)
            } else if let accountListViewController = factory.makeAccountListViewController() {
                viewControllers.append(accountListViewController)
            }
            
            if let accountViewController = view?.topViewController as? AccountViewController {
                if let url = accountViewController.account,
                    let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true) {
                    if components.scheme == "xmpp" {
                        if let host = components.host, let user = components.user {
                            let jid = JID(user: user, host: host, resource: nil)
                            if accounts.contains(jid) {
                                viewControllers.append(accountViewController)
                                accountViewController.navigationItem.leftBarButtonItem = nil
                            }
                        }
                    }
                }
            }
            
            return viewControllers
        }
    }
    
    private func signupViewController() -> SignupViewController? {
        guard let viewControllers = view?.viewControllers else { return nil }
        for viewController in viewControllers {
            if let signupViewController = viewController as? SignupViewController {
                return signupViewController
            }
        }
        return nil
    }
    
    private func accountListViewController() -> AccountListViewController? {
        guard let viewControllers = view?.viewControllers else { return nil }
        for viewController in viewControllers {
            if let accountListViewController = viewController as? AccountListViewController {
                return accountListViewController
            }
        }
        return nil
    }
    
    private func accountViewController(for uri: URL) -> AccountViewController? {
        guard let viewControllers = view?.viewControllers else { return nil }
        for viewController in viewControllers {
            if let accountViewController = viewController as? AccountViewController {
                if accountViewController.account == uri {
                    return accountViewController
                }
            }
        }
        return nil
    }
    
    private func accounts() -> [JID] {
        var accounts: [JID] = []
        for item in (try? keyChain.items()) ?? [] {
            if let account = JID(item.identifier) {
                accounts.append(account)
            }
        }
        return accounts
    }
    
    // MARK: Show
    
    func showAccount(for uri: URL, animated: Bool = true) {
        
        guard let navigationController = view else { return }
        guard let viewController: AccountViewController = {
            if let viewController = accountViewController(for: uri) {
                return viewController
            } else if let viewController = factory.makeAccountViewController(uri: uri) {
                return viewController
            } else {
                return nil
            }
        }() else { return }
        
        if navigationController.topViewController == viewController {
            return
        }
        
        if signupViewController() != nil {
            navigationController.setViewControllers([], animated: animated)
        } else if let list = accountListViewController() {
            if navigationController.topViewController != list {
                navigationController.popToViewController(list, animated: false)
                navigationController.pushViewController(viewController, animated: animated)
            } else {
                navigationController.pushViewController(viewController, animated: animated)
            }
        } else {
            navigationController.setViewControllers([viewController], animated: animated)
        }
    }
    
    // Notification Handling
    
    private lazy var notificationObservers = [NSObjectProtocol]()
    
    private func registerNotificationObservers() {
        let center = NotificationCenter.default
        
        notificationObservers.append(center.addObserver(
            forName: NSNotification.Name(rawValue: KeyChainDidAddItemNotification),
            object: keyChain,
            queue: OperationQueue.main
        ) { [weak self] _ in
            self?.setupView()
        })
        
        notificationObservers.append(center.addObserver(
            forName: NSNotification.Name(rawValue: KeyChainDidRemoveItemNotification),
            object: keyChain,
            queue: OperationQueue.main
        ) { [weak self] _ in
            self?.setupView()
        })
        
        notificationObservers.append(center.addObserver(
            forName: NSNotification.Name(rawValue: KeyChainDidRemoveAllItemsNotification),
            object: keyChain,
            queue: OperationQueue.main
        ) { [weak self] _ in
            self?.setupView()
        })
    }
    
    private func unregisterNotificationObservers() {
        let center = NotificationCenter.default
        for observer in notificationObservers {
            center.removeObserver(observer)
        }
        notificationObservers.removeAll()
    }
    
}

extension MainAccountNavigationPresenter: UINavigationControllerDelegate {
    
}
