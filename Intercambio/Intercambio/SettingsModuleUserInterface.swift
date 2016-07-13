//
//  SettingsModuleUserInterface.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 12.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation
import Fountain

public protocol SettingsModuleUserInterface : class {
    var dataSource: FTDataSource? { get set }
}
