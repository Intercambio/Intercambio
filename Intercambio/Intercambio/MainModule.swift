//
//  MainModule.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 01.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

public class MainModule : NSObject, UISplitViewControllerDelegate {
    
    class EmptyViewController : UIViewController {
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        }
    }
    
    public var navigationControllerModule: NavigationControllerModule?
    public var recentConversationsModule: RecentConversationsModule?
    public var conversationModule: ConversationModule?
    public var accountListModule: AccountListModule?
    public var accountModule: AccountModule?
    
    public func present(in window: UIWindow) {
        
        let tabBarController = UITabBarController()
        setupTabs(in: tabBarController)
        
        let splitViewController = UISplitViewController()
        splitViewController.delegate = self
        splitViewController.preferredDisplayMode = .allVisible
        splitViewController.viewControllers = [
            tabBarController,
            UINavigationController(rootViewController: EmptyViewController())
        ]
        
        window.rootViewController = splitViewController
        window.backgroundColor = UIColor.white
        window.makeKeyAndVisible()
    }
    
    private func setupTabs(in tabBarController: UITabBarController) {
        var tabs: [UINavigationController] = []
        
        if let viewController = self.recentConversationsModule?.makeRecentConversationsViewController() {
            if let navigationController = self.navigationControllerModule?.makeNavigationController(rootViewController: viewController) {
                tabs.append(navigationController)
            } else {
                tabs.append(UINavigationController(rootViewController: viewController))
            }
        }
        
        if let viewController = self.accountListModule?.makeAccountListViewController() {
            if let navigationController = self.navigationControllerModule?.makeNavigationController(rootViewController: viewController) {
                tabs.append(navigationController)
            } else {
                tabs.append(UINavigationController(rootViewController: viewController))
            }
        }
        
        tabBarController.viewControllers = tabs
    }
    
    public func presentConversation(for uri: URL, in window: UIWindow) {
        if let viewController = conversationModule?.makeConversationViewController(for: uri) {
            showDetailViewController(viewController, in: window)
        }
    }
    
    public func presentNewConversation(in window: UIWindow) {
        if let viewController = conversationModule?.makeConversationViewController(for: nil) {
            showDetailViewController(viewController, in: window)
        }
    }
    
    public func presentAccount(for uri: URL, in window: UIWindow) {
        if let viewController = accountModule?.makeAccountViewController(uri: uri) {
            if let navigationController = accountNavigationController(in: window) {
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
    
    private func showDetailViewController(_ vc: UIViewController, in window: UIWindow) {
        if let splitViewController = self.splitViewController(in: window) {
            splitViewController.showDetailViewController(vc, sender: self)
        }
    }
    
    private func accountNavigationController(in window: UIWindow) -> UINavigationController? {
        if let tabBarController = self.tabBarController(in: window) {
            for controller in tabBarController.viewControllers ?? [] {
                if let navigationController = controller as? UINavigationController {
                    if navigationController.viewControllers.first is AccountListViewController {
                        return navigationController
                    }
                }
            }
        }
        return nil
    }
    
    private func conversationNavigationController(in tabBarController: UITabBarController) -> UINavigationController? {
        for controller in tabBarController.viewControllers ?? [] {
            if let navigationController = controller as? UINavigationController {
                if navigationController.viewControllers.first is RecentConversationsViewController {
                    return navigationController
                }
            }
        }
        return nil
    }
    
    private func splitViewController(in window: UIWindow) -> UISplitViewController? {
        return window.rootViewController as? UISplitViewController
    }
    
    private func tabBarController(in window: UIWindow) -> UITabBarController? {
        if let splitViewController = self.splitViewController(in: window) {
            return splitViewController.viewControllers.first as? UITabBarController
        } else {
            return nil
        }
    }
    
    private func tabBarController(in splitViewController: UISplitViewController) -> UITabBarController? {
        return splitViewController.viewControllers.first as? UITabBarController
    }
    
    // UISplitViewControllerDelegate
    
    public func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
        if splitViewController.isCollapsed {
            if let tabBarController = self.tabBarController(in: splitViewController) {
                // TODO: push onto the correct navigation controller
                if let navigationController = tabBarController.viewControllers?.first as? UINavigationController {
                    navigationController.pushViewController(vc, animated: true)
                    return true
                }
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
        
        if let tabBarController = primaryViewController as? UITabBarController {
            if let navigationController = conversationNavigationController(in: tabBarController) {
                if navigationController.viewControllers.count > 1 {
                    
                    var secondaryViewControllers = navigationController.viewControllers
                    secondaryViewControllers.remove(at: 0)
                    
                    navigationController.popToRootViewController(animated: false)
                    
                    let secondaryNavigationController = UINavigationController()
                    secondaryNavigationController.viewControllers = secondaryViewControllers
                    
                    return secondaryNavigationController
                }
            }
        }
        return UINavigationController(rootViewController: EmptyViewController())
    }
    
    private func collapse(viewControllers: [UIViewController], onto tabBarController: UITabBarController) -> Bool {
        
        if viewControllers.first is ConversationViewController {
            if let navigationController = conversationNavigationController(in: tabBarController) {
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
}
