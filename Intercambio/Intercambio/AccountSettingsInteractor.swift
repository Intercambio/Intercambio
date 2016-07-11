//
//  AccountSettingsInteractor.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 08.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation

public let AccountSettingsInteractorDidUpdateAccount = Notification.Name("AccountSettingsInteractorDidUpdateAccount")

public protocol AccountSettingsInteractor {
    var account: AccountViewModel? { get }
    func enable() throws
    func disable() throws
    func connect() throws
    func update(options: Dictionary<String, AnyObject>) throws
}
