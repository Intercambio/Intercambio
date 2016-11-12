//
//  MainPresenterSplitViewControllerDelegate.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 07.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation


extension MainPresenter {
    
    class SplitViewControllerDelegate : UISplitViewControllerDelegate {
        
        var accountNavigationController: UINavigationController?
        var conversationNavigationController: UINavigationController?
        var tabBarController: UITabBarController?
        
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
    }
}
