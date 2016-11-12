//
//  MainModule.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 01.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

public class MainModule : NSObject, MainPresenterFactory {

    public var navigationControllerModule: NavigationControllerModule?
    public var recentConversationsModule: RecentConversationsModule?
    public var conversationModule: ConversationModule?
    public var accountListModule: AccountListModule?
    public var accountModule: AccountModule?
    
    public func makeMainViewController() -> MainViewController {
        
        let presenter = MainPresenter(factory: self)
        let view = MainViewController()
        presenter.view = view
        view.presenter = presenter
        
        return view
    }
    
    public func present(in window: UIWindow) {
        let controller = makeMainViewController()
        window.rootViewController = controller
        window.backgroundColor = UIColor.white
        window.makeKeyAndVisible()
    }
    
    public func presentConversation(for uri: URL, in window: UIWindow) {
        if let viewController = window.rootViewController as? MainViewController {
            viewController.showConversation(for: uri)
        }
    }
    
    public func presentNewConversation(in window: UIWindow) {
        if let viewController = window.rootViewController as? MainViewController {
            viewController.showNewConversation()
        }
    }
    
    public func presentAccount(for uri: URL, in window: UIWindow) {
        if let viewController = window.rootViewController as? MainViewController {
            viewController.showAccount(for: uri)
        }
    }
    
    // MARK: MainPresenterFactory

    func makeNavigationController() -> NavigationController? {
        return navigationControllerModule?.makeNavigationController()
    }
    
    func makeNavigationController(rootViewController: UIViewController) -> NavigationController? {
        return navigationControllerModule?.makeNavigationController(rootViewController: rootViewController)
    }
    
    func makeRecentConversationsViewController() -> RecentConversationsViewController? {
        return recentConversationsModule?.makeRecentConversationsViewController()
    }
    
    func makeConversationViewController(for uri: URL?) -> ConversationViewController? {
        return conversationModule?.makeConversationViewController(for: uri)
    }
    
    func makeAccountListViewController() -> AccountListViewController? {
        return accountListModule?.makeAccountListViewController()
    }
    
    func makeAccountViewController(uri: URL) -> AccountViewController? {
        return accountModule?.makeAccountViewController(uri: uri)
    }
}
