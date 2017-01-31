//
//  AccountProfileViewController.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 04.11.16.
//  Copyright © 2016, 2017 Tobias Kräntzer.
//
//  This file is part of Intercambio.
//
//  Intercambio is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option)
//  any later version.
//
//  Intercambio is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
//  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along with
//  Intercambio. If not, see <http://www.gnu.org/licenses/>.
//
//  Linking this library statically or dynamically with other modules is making
//  a combined work based on this library. Thus, the terms and conditions of the
//  GNU General Public License cover the whole combination.
//
//  As a special exception, the copyright holders of this library give you
//  permission to link this library with independent modules to produce an
//  executable, regardless of the license terms of these independent modules,
//  and to copy and distribute the resulting executable under terms of your
//  choice, provided that you also meet, for each linked independent module, the
//  terms and conditions of the license of that module. An independent module is
//  a module which is not derived from or based on this library. If you modify
//  this library, you must extend this exception to your version of the library.
//


import UIKit

public class AccountProfileViewController: UIViewController, AccountProfileView {
    
    @IBOutlet weak var profileContainerView: UIView!
    @IBOutlet weak var reconnectContainerView: UIView!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var connectionStateLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var nextReconnectionLabel: UILabel!
    @IBOutlet weak var reconnectButton: UIButton!
    
    var isProfileHidden: Bool = false
    
    var name: String? { didSet { updateUserInterface() } }
    var details: String? { didSet { updateUserInterface() } }
    var nextAction: String? { didSet { updateUserInterface() } }
    var errorMessage : String? { didSet { updateUserInterface() } }
    
    var connectionButtonEnabled: Bool = false { didSet { updateUserInterface() } }
    var connectionButtonHidden: Bool = false { didSet { updateUserInterface() } }
    
    var presenter: AccountProfileViewEventHandler?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        updateUserInterface()
    }
    
    @IBAction func connect(_ sender: UIButton) {
        presenter?.connectAccount()
    }
    
    @IBAction func showSettings(_ sender: UIButton) {
        presenter?.showAccountSettings()
    }
    
    private func updateUserInterface() {
        if isViewLoaded {
            self.profileContainerView.isHidden = isProfileHidden
            
            self.accountLabel.text = self.name
            self.connectionStateLabel.text = self.details
            self.nextReconnectionLabel.text = self.nextAction
            self.errorMessageLabel.text = self.errorMessage
            self.reconnectButton.isEnabled = self.connectionButtonEnabled
            self.reconnectContainerView.isHidden = self.connectionButtonHidden
        }
    }
}
