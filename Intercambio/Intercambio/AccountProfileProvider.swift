//
//  AccountProfileProvider.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 04.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation
import CoreXMPP

typealias AccountProfilePresentationModelConnectionState = CoreXMPP.AccountConnectionState

let AccountProfileProviderDidUpdateAccount = Notification.Name("AccountProfileProviderDidUpdateAccount")

protocol AccountProfileModel {
    var enabled: Bool { get }
    var state: AccountProfilePresentationModelConnectionState { get }
    var name: String? { get }
    var error: Error? { get }
    var nextConnectionAttempt: Date? { get }
}

protocol AccountProfileProvider : class {
    var accountURI: URL? { get }
    var account: AccountProfileModel? { get }
    func connect() throws
}
