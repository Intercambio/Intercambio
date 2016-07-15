//
//  SettingsModule.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 12.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import IntercambioCore

@objc public protocol SettingsModuleDelegate : class {
    @objc optional func settingsControllerDidCancel(_ controller: UIViewController)
    @objc optional func settingsControllerDidSave(_ controller: UIViewController)
    @objc optional func settingsController(_ controller: UIViewController, didFail: NSError)
}

public class SettingsModule : NSObject {
    
    private let service: CommunicationService
    
    init(service: CommunicationService) {
        self.service = service
    }
    
    public func viewController(uri: URL, delegate: SettingsModuleDelegate? = nil) -> (UIViewController?) {
        
        if let host = uri.host,
            let jid = JID(user: uri.user, host: host, resource: nil) {
            
            let interactor = SettingsModuleInteractorImpl(accountJID: jid,
                                                         keyChain: service.keyChain)
            
            let presenter = SettingsModulePresenterImpl()
            let viewControler = SettingsModuleViewController()
            
            // strong references (view controller -> presenter -> interactor)
            viewControler.eventHandler = presenter
            presenter.interactor = interactor
            
            // weak references
            interactor.presenter = presenter
            presenter.userInterface = viewControler
            
            viewControler.delegate = delegate
            return viewControler
        } else {
            return nil
        }
    }
}
