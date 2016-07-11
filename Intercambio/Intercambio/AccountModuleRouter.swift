//
//  AccountModuleRouter.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 11.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation

public protocol AccountModuleRouter {
    func showSettings(for accountURI: URL)
}
