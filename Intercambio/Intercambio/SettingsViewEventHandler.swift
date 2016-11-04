//
//  SettingsViewEventHandler.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 01.08.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation

protocol SettingsViewEventHandler : class {
    func setValue(_ value: Any?, forItemAt indexPath: IndexPath) -> Void
    func save()
    func cancel()
}
