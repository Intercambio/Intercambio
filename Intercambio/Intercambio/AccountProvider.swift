//
//  AccountProvider.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 08.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation

let AccountProviderDidUpdateAccount = Notification.Name("AccountProviderDidUpdateAccount")

protocol AccountProvider : class {
    var account: AccountPresentationModel? { get }
    func enable() throws
    func disable() throws
    func connect() throws
    func update(options: Dictionary<String, AnyObject>) throws
}
