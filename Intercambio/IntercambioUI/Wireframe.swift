//
//  Wireframe.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 02.11.16.
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

public class Wireframe: NSObject, NavigationControllerRouter, RecentConversationsRouter, AccountListRouter, AccountRouter, AccountProfileRouter, SignupRouter {
    
    public let window: UIWindow
    
    let mainModule: MainModule
    let navigationControllerModule: NavigationControllerModule
    let contactPickerModule: ContactPickerModule
    let recentConversationsModule: RecentConversationsModule
    let conversationModule: ConversationModule
    let accountListModule: AccountListModule
    let accountModule: AccountModule
    let settingsModule: SettingsModule
    let signupModule: SignupModule
    let authenticationModule: AuthenticationModule
    let accountProfileModule: AccountProfileModule
    
    public required init(window: UIWindow, service: CommunicationService) {
        self.window = window
        
        mainModule = MainModule(service: service)
        navigationControllerModule = NavigationControllerModule(service: service)
        contactPickerModule = ContactPickerModule(service: service)
        recentConversationsModule = RecentConversationsModule(service: service)
        conversationModule = ConversationModule(service: service)
        accountListModule = AccountListModule(service: service)
        accountModule = AccountModule(service: service)
        settingsModule = SettingsModule(service: service)
        signupModule = SignupModule(service: service)
        authenticationModule = AuthenticationModule()
        accountProfileModule = AccountProfileModule(service: service)
        
        accountModule.accountProfileModule = accountProfileModule
        
        conversationModule.contactPickerModule = contactPickerModule
        
        mainModule.navigationControllerModule = navigationControllerModule
        mainModule.recentConversationsModule = recentConversationsModule
        mainModule.conversationModule = conversationModule
        mainModule.accountListModule = accountListModule
        mainModule.accountModule = accountModule
        mainModule.signupModule = signupModule
        
        super.init()
        
        navigationControllerModule.router = self
        recentConversationsModule.router = self
        accountListModule.router = self
        accountModule.router = self
        accountProfileModule.router = self
        signupModule.router = self
    }
    
    public func presentLaunchScreen() {
        let storyboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
        window.rootViewController = storyboard.instantiateInitialViewController()
        window.backgroundColor = UIColor.white
        window.makeKeyAndVisible()
    }
    
    public func presentMainScreen() {
        mainModule.present(in: window)
    }
    
    public func presentConversation(for uri: URL) {
        mainModule.presentConversation(for: uri, in: window)
    }
    
    public func presentNewConversation() {
        mainModule.presentNewConversation(in: window)
    }
    
    public func presentAccount(for uri: URL) {
        mainModule.presentAccount(for: uri, in: window)
    }
    
    public func presentNewAccount() {
        signupModule.present(in: window)
    }
    
    public func presentSettings(for uri: URL) {
        settingsModule.presentSettings(for: uri, in: window)
    }
    
    public func presentLogin(for uri: URL, completion: ((String?) -> Void)?) {
        authenticationModule.presentLogin(for: uri, in: window, completion: completion)
    }
    
    public func present(_ error: Error, unrecoverable: Bool = false) {
        if unrecoverable {
            let title = NSLocalizedString("Unrecoverable Error", comment: "")
            let message = NSLocalizedString("An error has occured, that can't be resloved. Please contact support.", comment: "")
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            window.rootViewController?.present(alert, animated: true, completion: nil)
        } else {
            let title = NSLocalizedString("Error", comment: "")
            let message = error.localizedDescription
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                alert.dismiss(animated: true, completion: nil)
            })
            
            alert.addAction(action)
            
            window.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    // TODO: Rename Methods in the Router protocols of the Modules
    public func presentAccountUserInterface(for accountURI: URL) { presentAccount(for: accountURI) }
    public func presentNewAccountUserInterface() { presentNewAccount() }
    public func presentConversationUserInterface(for conversationURI: URL) { presentConversation(for: conversationURI) }
    public func presentNewConversationUserInterface() { presentNewConversation() }
    public func presentSettingsUserInterface(for accountURI: URL) { presentSettings(for: accountURI) }
}
