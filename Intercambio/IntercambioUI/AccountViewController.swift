//
//  AccountViewController.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 11.07.16.
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
        tabBarItem = UITabBarItem(title: NSLocalizedString("Accounts", comment: ""),
                                  image: UIImage(named: "779-users"),
                                  selectedImage: UIImage(named: "779-users-selected"))
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
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if navigationController?.viewControllers.index(of: self) == 0 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAccount(sender:)))

        } else {
            navigationItem.leftBarButtonItem = nil
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutTableHeaderView()
    }
    
    @objc private func addAccount(sender: AnyObject) {
        presenter?.addAccount()
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
