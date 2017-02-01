//
//  SignupModule.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 03.11.16.
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
import XMPPFoundation

@objc public protocol SignupRouter: class {
    func presentAccountUserInterface(for accountURI: URL)
    func presentNewAccountUserInterface()
}

public class SignupModule: NSObject {
    
    public weak var router: SignupRouter?
    
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
        
        alert.addTextField { textField in
            textField.placeholder = NSLocalizedString("romeo@example.com", comment: "")
            textField.keyboardType = .emailAddress
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
        }
        
        let interactor = SignupInteractor(keyChain: service.keyChain)
        
        let addAction = UIAlertAction(title: NSLocalizedString("Add", comment: ""), style: .default) {
            _ in
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
            _ in
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
