//
//  AccountModuleHeaderView.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 11.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

class AccountModuleHeaderView: UIView {

    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var connectionStateLabel: UILabel!
    @IBOutlet weak var nextConnectionAttemptLabel: UILabel!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var connectButton: UIButton!
    
    @IBAction func connect(_ sender: UIButton) {
    }
    
    @IBAction func showSettings(_ sender: UIButton) {
    }
}
