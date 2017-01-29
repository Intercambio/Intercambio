//
//  MainPresenterSplitViewControllerDelegate.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 07.11.16.
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
