//
//  AccountPresentationModel.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 01.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation
import CoreXMPP

typealias AccountPresentationModelConnectionState = CoreXMPP.AccountConnectionState

protocol AccountPresentationModel {
    var identifier: String { get }
    var accountURI: URL? { get }
    var enabled: Bool { get }
    var state: AccountPresentationModelConnectionState { get }
    var name: String? { get }
    var options: Dictionary<NSObject, AnyObject> { get }
    var error: NSError? { get }
    var nextConnectionAttempt: Date? { get }
}
