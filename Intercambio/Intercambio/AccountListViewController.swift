//
//  AccountListViewController.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 29.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import Fountain

public class AccountListViewController: UITableViewController, AccountListView {

    var eventHandler: AccountListViewEventHandler?
    var dataSource: FTDataSource? {
        didSet {
            tableViewAdapter?.dataSource = dataSource
        }
    }
    
    private var tableViewAdapter: FTTableViewAdapter?
    
    public init() {
        super.init(style: .plain)
        title = NSLocalizedString("Accounts", comment: "")
        tabBarItem = UITabBarItem(title: title,
                                  image: UIImage(named: "779-users"),
                                  selectedImage: UIImage(named: "779-users-selected"))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add(sender:)))

        
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "UITableViewCell")
        
        tableViewAdapter = FTTableViewAdapter(tableView: tableView)
        
        tableViewAdapter?.forRowsMatching(nil, useCellWithReuseIdentifier: "UITableViewCell") {
            (view, item, indexPath, dataSource) in
            if  let cell = view as? UITableViewCell,
                let account = item as? AccountListPresentationModel {
                cell.textLabel?.text = account.identifier
                cell.accessoryType = .disclosureIndicator
            }
        }
        
        tableViewAdapter?.delegate = self
        tableViewAdapter?.dataSource = dataSource
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let account = dataSource?.item(at: indexPath) as? AccountListPresentationModel {
            eventHandler?.didSelect(account)
        }
    }
    
    func add(sender: AnyObject) {
        eventHandler?.didTapNewAccount()
    }
}
