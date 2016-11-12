//
//  SignupViewController.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 12.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

public class SignupViewController: UIViewController, SignupView {
    
    var presenter: SignupViewEventHandler?
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = NSLocalizedString("Signup", comment: "")
        tabBarItem = UITabBarItem(title: title,
                                  image: UIImage(named: "779-users"),
                                  selectedImage: UIImage(named: "779-users-selected"))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        title = NSLocalizedString("Signup", comment: "")
        tabBarItem = UITabBarItem(title: title,
                                  image: UIImage(named: "779-users"),
                                  selectedImage: UIImage(named: "779-users-selected"))
    }
    
    @IBAction func addAccount() {
        presenter?.addAccount()
    }
}
