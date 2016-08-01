//
//  SettingsProvider.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 01.08.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation

struct Settings {
    var websocketURL: URL?
}

protocol SettingsProvider : class {
    var identifier: String { get }
    var settings: Settings { get }
    func update(settings: Settings) throws
}
