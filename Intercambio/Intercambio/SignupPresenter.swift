//
//  SignupPresenter.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 12.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation

class SignupPresenter : SignupViewEventHandler {
    weak var view: SignupView?
    var router: SignupRouter?
    
    func addAccount() {
        router?.presentNewAccountUserInterface()
    }
}
