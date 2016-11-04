//
//  AccountProfileView.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 04.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation

protocol AccountProfileView : class {
    var name: String? { get set}
    var details: String? { get set}
    var nextAction: String? { get set }
    var errorMessage : String? { get set }
    var connectionButtonEnabled: Bool { get set }
    var connectionButtonHidden: Bool { get set }
}
