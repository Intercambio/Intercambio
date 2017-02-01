//
//  SettingsModule.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 12.07.16.
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
import XMPPFoundation
import IntercambioCore

public class SettingsModule: NSObject, SettingsViewControllerDelegate {
    
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

@objc public protocol SettingsViewControllerDelegate: class {
    func settingsDidCancel(_ settingsViewController: SettingsViewController) -> Void
    func settingsDidSave(_ settingsViewController: SettingsViewController) -> Void
    func settingsDidRemoveAccount(_ settingsViewController: SettingsViewController) -> Void
}

public extension SettingsViewController {
    
    private class DelegateProxy: SettingsPresenterEventHandler {
        weak var delegate: SettingsViewControllerDelegate?
        weak var viewController: SettingsViewController?
        
        func settingsDidSave(_: SettingsPresenter) {
            if let delegate = self.delegate,
                let viewController = self.viewController {
                delegate.settingsDidSave(viewController)
            }
        }
        
        func settingsDidCancel(_: SettingsPresenter) {
            if let delegate = self.delegate,
                let viewController = self.viewController {
                delegate.settingsDidCancel(viewController)
            }
        }
        
        func settingsDidRemove(_: SettingsPresenter) {
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
            let proxy = presenter.eventHandler as? DelegateProxy {
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
