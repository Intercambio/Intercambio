//
//  SignupModule.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 03.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import IntercambioCore

@objc public protocol SignupRouter : class {
    func presentAccountUserInterface(for accountURI: URL)
    func presentNewAccountUserInterface()
}

public class SignupModule : NSObject {
    
    weak public var router: SignupRouter?
    
    public let service: CommunicationService
    public init(service: CommunicationService) {
        self.service = service
    }
    
    public func makeSignupViewController() -> SignupViewController {
        let controller = SignupViewController()
        let presenter = SignupPresenter()
        presenter.view = controller
        presenter.router = router
        controller.presenter = presenter
        return controller
    }
    
    public func present(in window: UIWindow) {
        
        let title = NSLocalizedString("Add Account", comment: "")
        let message = NSLocalizedString("Enter the address of the account you want to use in this App. The server must support Websockets.", comment: "")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("romeo@example.com", comment: "")
            textField.keyboardType = .emailAddress
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
        }
        
        let interactor = SignupInteractor(keyChain: service.keyChain)
        
        let addAction = UIAlertAction(title: NSLocalizedString("Add", comment: ""), style: .default) {
            action in
            if let address = alert.textFields?.first?.text {
                if let jid = JID(address) {
                    interactor.addAccount(jid)
                    var components = URLComponents()
                    components.scheme = "xmpp"
                    components.host = jid.host
                    components.user = jid.user
                    if let url = components.url {
                        self.router?.presentAccountUserInterface(for: url)
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) {
            action in
        }
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        if let viewControler = window.rootViewController?.presentedViewController {
            viewControler.present(alert, animated: true, completion: nil)
        } else {
            window.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}
