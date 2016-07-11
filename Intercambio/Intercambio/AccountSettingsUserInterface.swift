//
//  AccountSettingsInterface.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 11.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation

public protocol AccountSettingsUserInterface {
    
    var accountLabel: String? { get set}
    var stateLabel: String? { get set}
    var nextConnectionLabel: String? { get set }
    var errorMessageLabel : String? { get set }
    
    var connectionButtonEnabled: Bool { get set }
    var connectionButtonHidden: Bool { get set }
    var nextConnectionLabelHidden: Bool { get set }
    var errorMessageLabelHidden: Bool { get set }
}
