//
//  SettingsModule.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 12.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import IntercambioCore

public class SettingsModule : NSObject, SettingsViewControllerDelegate {

    public let service: CommunicationService
    
    public init(service: CommunicationService) {
        self.service = service
    }

    public func presentSettings(for uri: URL, in window: UIWindow) {
        if let viewController = makeSettingsViewController(uri: uri),
            let rootViewController = window.rootViewController {
            viewController.delegate = self
            
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.modalTransitionStyle = .coverVertical
            navigationController.modalPresentationStyle = .formSheet
            rootViewController.present(navigationController, animated: true, completion: nil)
        }
    }

    public func makeSettingsViewController(uri: URL) -> SettingsViewController? {
        let controller = SettingsViewController(service: service, account: uri)
        return controller
    }
    
    // SettingsViewControllerDelegate
    
    public func settingsDidSave(_ settingsViewController: SettingsViewController) {
        settingsViewController.dismiss(animated: true, completion: nil)
    }
    
    public func settingsDidCancel(_ settingsViewController: SettingsViewController) {
        settingsViewController.dismiss(animated: true, completion: nil)
    }
    
    public func settingsDidRemoveAccount(_ settingsViewController: SettingsViewController) {
        settingsViewController.dismiss(animated: true, completion: nil)
    }
}

@objc public protocol SettingsViewControllerDelegate : class {
    func settingsDidCancel(_ settingsViewController: SettingsViewController) -> Void
    func settingsDidSave(_ settingsViewController: SettingsViewController) -> Void
    func settingsDidRemoveAccount(_ settingsViewController: SettingsViewController) -> Void
}

public extension SettingsViewController {
    
    private class DelegateProxy : SettingsPresenterEventHandler {
        weak var delegate: SettingsViewControllerDelegate?
        weak var viewController: SettingsViewController?

        func settingsDidSave(_ settingsPresenter: SettingsPresenter) {
            if let delegate = self.delegate,
               let viewController = self.viewController {
               delegate.settingsDidSave(viewController)
            }
        }
        
        func settingsDidCancel(_ settingsPresenter: SettingsPresenter) {
            if let delegate = self.delegate,
                let viewController = self.viewController {
                delegate.settingsDidCancel(viewController)
            }
        }
        
        func settingsDidRemove(_ settingsPresenter: SettingsPresenter) {
            if let delegate = self.delegate,
                let viewController = self.viewController {
                delegate.settingsDidRemoveAccount(viewController)
            }
        }
    }
    
    public convenience init?(service: CommunicationService, account uri: URL) {
        if let host = uri.host {
            
            let jid = JID(user: uri.user, host: host, resource: nil)
            
            self.init()
            
            let presenter = SettingsPresenter(accountJID: jid, keyChain: service.keyChain)
            presenter.view = self
            self.presenter = presenter
            
            let proxy = DelegateProxy()
            proxy.viewController = self
            presenter.eventHandler = proxy
            
        } else {
            return nil
        }
    }
    
    public weak var delegate: SettingsViewControllerDelegate? {
        set {
            if let proxy = delegateProxy {
                proxy.delegate = newValue
            }
        }
        get {
            if let proxy = delegateProxy {
                return proxy.delegate
            } else {
                return nil
            }
        }
    }
    
    private var delegateProxy: DelegateProxy? {
        if let presenter = self.presenter as? SettingsPresenter,
            let proxy = presenter.eventHandler as? DelegateProxy{
            return proxy
        }
        return nil
    }
    
    var account: URL? {
        if let presenter = self.presenter as? SettingsPresenter {
            var components = URLComponents()
            components.scheme = "xmpp"
            components.host = presenter.accountJID.host
            components.user = presenter.accountJID.user
            return components.url
        }
        return nil
    }
}
