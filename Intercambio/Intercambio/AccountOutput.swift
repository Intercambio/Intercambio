//
//  AccountOutput.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 08.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation

protocol AccountOutput : class {
    func present(account: AccountPresentationModel)
}
