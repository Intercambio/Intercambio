    //
//  AccountPresenter.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 11.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation

class AccountPresenter : AccountViewEventHandler {
    weak var view: AccountView?
    var router: AccountRouter?
}
