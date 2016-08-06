//
//  SettingsView.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 01.08.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation
import Fountain

protocol SettingsView : class {
    var dataSource: FTDataSource? { get set }
    var identifier: String? { get set }
}