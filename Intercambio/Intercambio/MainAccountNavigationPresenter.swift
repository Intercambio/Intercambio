//
//  MainAccountNavigationPresenter.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 12.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
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
                if  let url = accountViewController.account,
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
        for item in (try? keyChain.fetch()) ?? [] {
            if let i = item as? KeyChainItem {
                accounts.append(i.jid)
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
        
        notificationObservers.append(center.addObserver(forName: NSNotification.Name(rawValue: KeyChainDidAddItemNotification),
                                                        object: keyChain,
                                                        queue: OperationQueue.main) { [weak self] (notification) in
                                                            self?.setupView()
        })
        
        notificationObservers.append(center.addObserver(forName: NSNotification.Name(rawValue: KeyChainDidRemoveItemNotification),
                                                        object: keyChain,
                                                        queue: OperationQueue.main) { [weak self] (notification) in
                                                            self?.setupView()
        })
        
        notificationObservers.append(center.addObserver(forName: NSNotification.Name(rawValue: KeyChainDidClearNotification),
                                                        object: keyChain,
                                                        queue: OperationQueue.main) { [weak self] (notification) in
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
