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
    
    public func viewController(uri: URL, completion: ((saved: Bool, controller: UIViewController) -> Void)?) -> (UIViewController?) {
        
        if let host = uri.host, let jid = JID(user: uri.user, host: host, resource: nil) {
            
            let interactor = SettingsInteractor(accountJID: jid, keyChain: service.keyChain)
            let presenter = SettingsPresenter()
            let view = SettingsViewController()
            
            // strong references (view controller -> presenter -> interactor)
            view.eventHandler = presenter
            presenter.interactor = interactor
            
            // weak references
            interactor.presenter = presenter
            presenter.userInterface = view
            if let c = completion {
                presenter.completion = { [weak view] saved in
                    if let v = view {
                        c(saved: saved, controller: v)
                    }
                }
            }
            
            return view
            
        } else {
            return nil
        }
    }
}
