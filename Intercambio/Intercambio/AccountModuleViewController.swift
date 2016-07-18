//
//  AccountModuleViewController.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 11.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

class AccountModuleViewController: UITableViewController, AccountModuleUserInterface {

    var accountLabel: String? { didSet { updateUserInterface() } }
    var stateLabel: String? { didSet { updateUserInterface() } }
    var nextConnectionLabel: String? { didSet { updateUserInterface() } }
    var errorMessageLabel : String? { didSet { updateUserInterface() } }
    
    var connectionButtonEnabled: Bool = false { didSet { updateUserInterface() } }
    var connectionButtonHidden: Bool = false { didSet { updateUserInterface() } }
    var nextConnectionLabelHidden: Bool = true { didSet { updateUserInterface() } }
    var errorMessageLabelHidden: Bool = true { didSet { updateUserInterface() } }

    internal var eventHandler: AccountModuleEventHandler?
    
    private var headerView: AccountModuleHeaderView?
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "AccountModuleHeaderView", bundle: Bundle.main)
        self.headerView = nib.instantiate(withOwner: self, options: nil).first as? AccountModuleHeaderView
        self.tableView.tableHeaderView = self.headerView
        
        self.headerView?.settingsButton.addTarget(self, action: #selector(showSettings), for: .touchUpInside)
        
        updateUserInterface()
        layoutTableHeaderView()
    }
    
    @IBAction func connect(_ sender: UIButton) {
        eventHandler?.connectAccount()
    }
    
    @IBAction func showSettings(_ sender: UIButton) {
        eventHandler?.showAccountSettings()
    }
    
    private func updateUserInterface() {
        self.headerView?.accountLabel.text = self.accountLabel
        self.headerView?.connectionStateLabel.text = self.stateLabel
    }
    
    private func layoutTableHeaderView() {
        if let headerView = self.headerView {
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()
            let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            var frame = headerView.frame
            frame.size.height = height
            headerView.frame = frame
        }
    }
}
