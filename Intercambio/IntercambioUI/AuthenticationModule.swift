//
//  AuthenticationModule.swift
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

public class AuthenticationModule {
    
    public func presentLogin(for uri: URL, in window: UIWindow, completion: ((String?) -> Void)?) {
        
        let title = NSLocalizedString("Login", comment: "")
        let message = String(format: NSLocalizedString("Please enter the password for '%@'.", comment: ""), uri.absoluteString)
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.isSecureTextEntry = true
            textField.placeholder = NSLocalizedString("Password", comment: "")
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
        }
        
        let addAction = UIAlertAction(title: NSLocalizedString("Login", comment: ""), style: .default) {
            _ in
            completion?(alert.textFields?.first?.text)
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) {
            _ in
            completion?(nil)
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
