//
//  MainModule.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 01.11.16.
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
import IntercambioCore

public class MainModule : NSObject, MainPresenterFactory {

    public let service: CommunicationService
    
    public init(service: CommunicationService) {
        self.service = service
    }
    
    public var navigationControllerModule: NavigationControllerModule?
    public var recentConversationsModule: RecentConversationsModule?
    public var conversationModule: ConversationModule?
    public var accountListModule: AccountListModule?
    public var accountModule: AccountModule?
    public var signupModule: SignupModule?
    
    public func makeMainViewController() -> MainViewController {
        
        let presenter = MainPresenter(keyChain: service.keyChain, factory: self)
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
    
    func makeSignupViewController() -> SignupViewController? {
        return signupModule?.makeSignupViewController()
    }
}
