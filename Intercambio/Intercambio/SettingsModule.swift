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
    
    private let service: CommunicationService
    
    init(service: CommunicationService) {
        self.service = service
    }
    
    public func viewController(uri: URL) -> (UIViewController?) {
        
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
            
            return viewControler
        } else {
            return nil
        }
    }
}
