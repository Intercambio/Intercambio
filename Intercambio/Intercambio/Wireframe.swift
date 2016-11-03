//
//  Wireframe.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 02.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import  IntercambioCore

public class Wireframe : NSObject, NavigationControllerRouter, RecentConversationsRouter, AccountListRouter, AccountRouter {
    
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
    
    public required init(window: UIWindow, service: CommunicationService) {
        self.window = window

        mainModule = MainModule()
        navigationControllerModule = NavigationControllerModule(service: service)
        contactPickerModule = ContactPickerModule(service: service)
        recentConversationsModule = RecentConversationsModule(service: service)
        conversationModule = ConversationModule(service: service)
        accountListModule = AccountListModule(service: service)
        accountModule = AccountModule(service: service)
        settingsModule = SettingsModule(service: service)
        signupModule = SignupModule(service: service)
        authenticationModule = AuthenticationModule()

        conversationModule.contactPickerModule = contactPickerModule
        
        mainModule.navigationControllerModule = navigationControllerModule
        mainModule.recentConversationsModule = recentConversationsModule
        mainModule.conversationModule = conversationModule
        mainModule.accountListModule = accountListModule
        mainModule.accountModule = accountModule
        
        super.init()
        
        navigationControllerModule.router = self
        recentConversationsModule.router = self
        accountListModule.router = self
        accountModule.router = self
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
            let action = UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
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
    public func presentNewConversationUserInterface(){ presentNewConversation() }
    public func presentSettingsUserInterface(for accountURI: URL) { presentSettings(for: accountURI) }
}
