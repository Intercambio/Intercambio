//
//  AccountModuleInteractor.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 08.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation

public let AccountModuleInteractorDidUpdateAccount = Notification.Name("AccountModuleInteractorDidUpdateAccount")

public protocol AccountModuleInteractor {
    var account: AccountViewModel? { get }
    func enable() throws
    func disable() throws
    func connect() throws
    func update(options: Dictionary<String, AnyObject>) throws
}
