//
//  MainPresenter.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 07.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

protocol MainPresenterFactory {
    func makeNavigationController(rootViewController: UIViewController) -> NavigationController?
    func makeRecentConversationsViewController() -> RecentConversationsViewController?
    func makeConversationViewController(for uri: URL?) -> ConversationViewController?
    func makeAccountListViewController() -> AccountListViewController?
    func makeAccountViewController(uri: URL) -> AccountViewController?
}

class MainPresenter: NSObject, UISplitViewControllerDelegate {

    weak var view: UISplitViewController? {
        didSet {
            setupView()
        }
    }
    
    let factory: MainPresenterFactory
    init(factory: MainPresenterFactory) {
        self.factory = factory
        super.init()
    }
    
    private var accountNavigationController: UINavigationController?
    private var conversationNavigationController: UINavigationController?
    private var tabBarController: UITabBarController?
    
    // MARK: Setup
    
    private func setupView() {
        if let splitViewController = view {
            let tabBarController = setupTabs()
            splitViewController.delegate = self
            splitViewController.preferredDisplayMode = .allVisible
            splitViewController.viewControllers = [
                tabBarController,
                UINavigationController(rootViewController: EmptyViewController())
            ]
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
        
        if let viewController = factory.makeAccountListViewController() {
            if let navigationController = factory.makeNavigationController(rootViewController: viewController) {
                accountNavigationController = navigationController
                tabs.append(navigationController)
            } else {
                let navigationController = UINavigationController(rootViewController: viewController)
                accountNavigationController = navigationController
                tabs.append(navigationController)
            }
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
        if let viewController = factory.makeAccountViewController(uri: uri) {
            if let navigationController = accountNavigationController {
                var animated = true
                if navigationController.viewControllers.count > 1 {
                    animated = false
                    navigationController.popToRootViewController(animated: animated)
                }
                
                if let tabBarController = navigationController.tabBarController {
                    if tabBarController.selectedViewController !== navigationController {
                        if let index = tabBarController.viewControllers?.index(of: navigationController) {
                            tabBarController.selectedIndex = index
                            animated = false
                        }
                    }
                }
                
                navigationController.pushViewController(viewController, animated: animated)
            }
        }
    }
    
    private func showDetailViewController(_ vc: UIViewController) {
            view?.showDetailViewController(vc, sender: self)
    }
    
    // MARK: UISplitViewControllerDelegate
    
    public func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
        if splitViewController.isCollapsed {
            // TODO: push onto the correct navigation controller
            if let navigationController = conversationNavigationController {
                navigationController.pushViewController(vc, animated: true)
                return true
            }
            return false
        } else {
            let navigationController = UINavigationController(rootViewController: vc)
            var viewControllers: [UIViewController] = []
            if let primeryViewController = splitViewController.viewControllers.first {
                viewControllers.append(primeryViewController)
            }
            viewControllers.append(navigationController)
            splitViewController.viewControllers = viewControllers
            return true
        }
    }
    
    public func splitViewController(_ splitViewController: UISplitViewController,
                                    collapseSecondary secondaryViewController: UIViewController,
                                    onto primaryViewController: UIViewController) -> Bool {
        
        if let navigationController = secondaryViewController as? UINavigationController {
            if navigationController.viewControllers.first is EmptyViewController {
                // just "drop" an empty view controller
                return true
            }
        }
        
        if let navigationController = secondaryViewController as? UINavigationController,
            let tabBarController = primaryViewController as? UITabBarController {
            return collapse(viewControllers: navigationController.viewControllers, onto: tabBarController)
        } else {
            return false
        }
    }
    
    public func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        
        if let navigationController = conversationNavigationController {
            if navigationController.viewControllers.count > 1 {
                
                var secondaryViewControllers = navigationController.viewControllers
                secondaryViewControllers.remove(at: 0)
                
                navigationController.popToRootViewController(animated: false)
                
                let secondaryNavigationController = UINavigationController()
                secondaryNavigationController.viewControllers = secondaryViewControllers
                
                return secondaryNavigationController
            }
        }
        return UINavigationController(rootViewController: EmptyViewController())
    }
    
    private func collapse(viewControllers: [UIViewController], onto tabBarController: UITabBarController) -> Bool {
        
        if viewControllers.first is ConversationViewController {
            if let navigationController = conversationNavigationController {
                navigationController.popToRootViewController(animated: false)
                var newViewControllers = navigationController.viewControllers
                newViewControllers.append(contentsOf: viewControllers)
                navigationController.viewControllers = newViewControllers
                
                if tabBarController.selectedViewController !== navigationController {
                    if let index = tabBarController.viewControllers?.index(of: navigationController) {
                        tabBarController.selectedIndex = index
                    }
                }
                
                return true
            } else {
                return false
            }
        } else {
            // Currently only a conversation view controller should be presented as a detail view controller
            return false
        }
    }

    // MARK: Empty View
    
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
