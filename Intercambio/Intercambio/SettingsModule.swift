//
//  SettingsModule.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 12.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import IntercambioCore

public class SettingsModule : NSObject {
    
    public let service: CommunicationService
    
    public init(service: CommunicationService) {
        self.service = service
    }

    public func makeSettingsViewController(uri: URL) -> SettingsViewController? {
        let controller = SettingsViewController(service: service, account: uri)
        return controller
    }
}

@objc public protocol SettingsViewControllerDelegate : class {
    func settingsDidCancel(_ settingsViewController: SettingsViewController) -> Void
    func settingsDidSave(_ settingsViewController: SettingsViewController) -> Void
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
    }
    
    public convenience init?(service: CommunicationService, account uri: URL) {
        if let host = uri.host, let jid = JID(user: uri.user, host: host, resource: nil) {
            
            self.init()
            
            let interactor = SettingsInteractor(accountJID: jid, keyChain: service.keyChain)
            let presenter = SettingsPresenter()
            
            // strong references (view controller -> presenter -> interactor)
            eventHandler = presenter
            presenter.interactor = interactor
            
            // weak references
            interactor.presenter = presenter
            presenter.userInterface = self
            
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
        if let presenter = self.eventHandler as? SettingsPresenter,
            let proxy = presenter.eventHandler as? DelegateProxy{
            return proxy
        }
        return nil
    }
}
