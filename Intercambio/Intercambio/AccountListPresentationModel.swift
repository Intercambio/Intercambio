//
//  AccountListPresentationModel.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 18.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation

public protocol AccountListPresentationModel : class {
    var identifier: String { get }
    var accountURI: URL? { get }
    var name: String? { get }
}
