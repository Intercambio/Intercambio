//
//  SettingsModuleInteractor.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 12.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation

public protocol SettingsModuleInteractor : class {
    var accountURI: URL? { get }
    var identifier: String { get }
    var settings: Settings { get }
    func update(settings: Settings) throws
}
