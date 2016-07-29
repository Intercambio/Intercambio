//
//  AccountListViewEventHandler.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 29.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation

protocol AccountListViewEventHandler: class {
    func didTapNewAccount()
    func didSelect(_ account: AccountListPresentationModel)
}
