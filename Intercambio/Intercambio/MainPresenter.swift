//
//  MainPresenter.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 07.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import IntercambioCore

protocol MainPresenterFactory : MainAccountNavigationPresenterFactory {
    func makeNavigationController(rootViewController: UIViewController) -> NavigationController?
    func makeNavigationController() -> NavigationController?
    func makeRecentConversationsViewController() -> RecentConversationsViewController?
    func makeConversationViewController(for uri: URL?) -> ConversationViewController?
}

class MainPresenter: NSObject {

    weak var view: UISplitViewController? {
        didSet {
            setupView()
        }
    }
    
    let keyChain: KeyChain
    let factory: MainPresenterFactory
    
    init(keyChain: KeyChain, factory: MainPresenterFactory) {
        self.keyChain = keyChain
        self.factory = factory
        super.init()
    }
    
    private lazy var accountNavigationController: UINavigationController? = {
        return self.factory.makeNavigationController()
    }()
    private lazy var accountNavigationPresenter: MainAccountNavigationPresenter = {
       return MainAccountNavigationPresenter(keyChain: self.keyChain, factory: self.factory)
    }()
    
    private var conversationNavigationController: UINavigationController?
    private var tabBarController: UITabBarController?
    
    private var splitViewControllerDelegate: SplitViewControllerDelegate?
    
    // MARK: Setup
    
    private func setupView() {
        if let splitViewController = view {
            let tabBarController = setupTabs()
            splitViewController.preferredDisplayMode = .allVisible
            splitViewController.viewControllers = [
                tabBarController,
                UINavigationController(rootViewController: EmptyViewController())
            ]
            
            splitViewControllerDelegate = SplitViewControllerDelegate()
            splitViewControllerDelegate?.accountNavigationController = accountNavigationController
            splitViewControllerDelegate?.conversationNavigationController = conversationNavigationController
            splitViewControllerDelegate?.tabBarController = tabBarController
            splitViewController.delegate = splitViewControllerDelegate
        }
    }
    
    private func setupTabs() -> UITabBarController {
        
        var tabs: [UINavigationController] = []
        
        if let viewController = factory.makeRecentConversationsViewController() {
            if let navigationController = factory.makeNavigationController(rootViewController: viewController) {
                conversationNavigationController = navigationController
                tabs.append(navigationController)
            } else {
                let navigationController = UINavigationController(rootViewController: viewController)
                conversationNavigationController = navigationController
                tabs.append(navigationController)
            }
        }
        
        if let navigationController = accountNavigationController {
            accountNavigationPresenter.view = navigationController
            tabs.append(navigationController)
        }
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = tabs
        self.tabBarController = tabBarController
        return tabBarController
    }
    
    // MARK: Show
    
    func showConversation(for uri: URL) {
        if let viewController = factory.makeConversationViewController(for: uri) {
            showDetailViewController(viewController)
        }
    }
    
    func showNewConversation() {
        if let viewController = factory.makeConversationViewController(for: nil) {
            showDetailViewController(viewController)
        }
    }
    
    func showAccount(for uri: URL) {
        
        var animated = true
        
        if let navigationController = accountNavigationController,
           let tabBarController = self.tabBarController {
            
            if tabBarController.selectedViewController !== navigationController {
                if let index = tabBarController.viewControllers?.index(of: navigationController) {
                    tabBarController.selectedIndex = index
                    animated = false
                }
            }
    
            accountNavigationPresenter.showAccount(for: uri, animated: animated)
        }
    }
    
    private func showDetailViewController(_ vc: UIViewController) {
        view?.showDetailViewController(vc, sender: self)
    }
}

extension MainPresenter {
    class EmptyViewController : UIViewController {
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        }
    }
}

public extension MainViewController {
    
    func showConversation(for uri: URL) {
        presenter?.showConversation(for: uri)
    }
    
    func showNewConversation() {
        presenter?.showNewConversation()
    }
    
    func showAccount(for uri: URL) {
        presenter?.showAccount(for: uri)
    }
}
