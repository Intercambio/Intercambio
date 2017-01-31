//
//  MainPresenter.swift
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


import UIKit
import KeyChain
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
