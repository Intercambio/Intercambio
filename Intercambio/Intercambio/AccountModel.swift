//
//  AccountModel.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 01.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation
import CoreXMPP

public typealias AccountConnectionState = CoreXMPP.AccountConnectionState

public protocol AccountViewModel {
    var identifier: String { get }
    var enabled: Boolean { get }
    var state: AccountConnectionState { get }
    var name: String? { get }
    var options: Dictionary<NSObject, AnyObject> { get }
}
