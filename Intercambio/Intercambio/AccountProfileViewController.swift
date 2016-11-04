//
//  AccountProfileViewController.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 04.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

public class AccountProfileViewController: UIViewController, AccountProfileView {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var connectionStateLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var reconnectContainerView: UIView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var nextReconnectionLabel: UILabel!
    @IBOutlet weak var reconnectButton: UIButton!
    
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
            self.accountLabel.text = self.name
            self.connectionStateLabel.text = self.details
            self.nextReconnectionLabel.text = self.nextAction
            self.errorMessageLabel.text = self.errorMessage
            self.reconnectButton.isEnabled = self.connectionButtonEnabled
            self.reconnectContainerView.isHidden = self.connectionButtonHidden
        }
    }
}
