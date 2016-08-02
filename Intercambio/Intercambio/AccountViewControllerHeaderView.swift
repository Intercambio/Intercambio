//
//  AccountViewControllerHeaderView.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 11.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

class AccountViewControllerHeaderView: UIView {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var connectionStateLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    
    
    @IBOutlet weak var reconnectContainerView: UIView!
    
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var nextReconnectionLabel: UILabel!
    @IBOutlet weak var reconnectButton: UIButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2.0
    }
}
