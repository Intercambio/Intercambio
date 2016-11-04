//
//  AccountViewController.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 11.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

public class AccountViewController: UITableViewController, AccountView {

    var accountProfileViewController: UIViewController? {
        willSet {
            if let viewController = accountProfileViewController {
                tableView.tableHeaderView = nil
                viewController.view.removeFromSuperview()
                viewController.removeFromParentViewController()
            }
        }
        didSet {
            if let viewController = accountProfileViewController {
                if isViewLoaded {
                    addChildViewController(viewController)
                    tableView.tableHeaderView = viewController.view
                }
            }
        }
    }
    
    var presenter: AccountViewEventHandler?
    
    public init() {
        super.init(style: .grouped)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if let viewController = accountProfileViewController {
            addChildViewController(viewController)
            tableView.tableHeaderView = viewController.view
        }
        
        layoutTableHeaderView()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutTableHeaderView()
    }

    private func layoutTableHeaderView() {
        if let headerView = self.tableView.tableHeaderView {
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()
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
