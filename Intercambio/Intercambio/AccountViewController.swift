//
//  AccountViewController.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 11.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

class AccountViewController: UITableViewController, AccountView {

    var accountLabel: String? { didSet { updateUserInterface() } }
    var stateLabel: String? { didSet { updateUserInterface() } }
    var nextConnectionLabel: String? { didSet { updateUserInterface() } }
    var errorMessageLabel : String? { didSet { updateUserInterface() } }
    
    var connectionButtonEnabled: Bool = false { didSet { updateUserInterface() } }
    var connectionButtonHidden: Bool = false { didSet { updateUserInterface() } }

    var eventHandler: AccountViewEventHandler?
    
    private var headerView: AccountViewControllerHeaderView?
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "AccountViewControllerHeaderView", bundle: Bundle.main)
        self.headerView = nib.instantiate(withOwner: self, options: nil).first as? AccountViewControllerHeaderView
        self.tableView.tableHeaderView = self.headerView
        
        self.headerView?.reconnectButton.addTarget(self, action: #selector(connect), for: .touchUpInside)
        self.headerView?.settingsButton.addTarget(self, action: #selector(showSettings), for: .touchUpInside)
        
        updateUserInterface()
        layoutTableHeaderView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        
        self.headerView?.nextReconnectionLabel.text = self.nextConnectionLabel
        self.headerView?.errorMessageLabel.text = self.errorMessageLabel
        
        self.headerView?.reconnectButton.isEnabled = self.connectionButtonEnabled
        self.headerView?.reconnectContainerView.isHidden = self.connectionButtonHidden
        
        tableView.setNeedsLayout()
    }
    
    private func layoutTableHeaderView() {
        if let headerView = self.headerView {
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()
            headerView.errorMessageLabel.preferredMaxLayoutWidth = UIEdgeInsetsInsetRect(tableView.bounds, tableView.layoutMargins).width
            let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            if round(height) != round(headerView.bounds.size.height) {
                var frame = headerView.frame
                frame.size.height = height
                headerView.frame = frame
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
    }
}
