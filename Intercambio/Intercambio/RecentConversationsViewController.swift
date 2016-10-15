//
//  RecentConversationsViewController.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 10.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import Fountain

class RecentConversationsViewController: UITableViewController, RecentConversationsView {

    var eventHandler: RecentConversationsViewEventHandler?
    var dataSource: FTDataSource? {
        didSet {
            tableViewAdapter?.dataSource = dataSource
        }
    }
    
    private var tableViewAdapter: FTTableViewAdapter?
    
    init() {
        super.init(style: .plain)
        title = NSLocalizedString("Conversations", comment: "")
        tabBarItem = UITabBarItem(title: NSLocalizedString("Conversations", comment: ""),
                                  image: #imageLiteral(resourceName: "906-chat-3"),
                                  selectedImage: #imageLiteral(resourceName: "906-chat-3-selected"))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewAdapter = FTTableViewAdapter(tableView: tableView)
        
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "conversation")
        tableViewAdapter?.forRowsMatching(nil, useCellWithReuseIdentifier: "conversation") {
            (view, item, indexPath, dataSource) in
            if  let cell = view as? UITableViewCell,
                let conversation = item as? RecentConversationsViewModel {
                cell.textLabel?.text = conversation.title
                cell.detailTextLabel?.text = conversation.subtitle
            }
        }
        
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "undefined")
        tableViewAdapter?.forRowsMatching(nil, useCellWithReuseIdentifier: "undefined") {
            (view, item, indexPath, dataSource) in
            if  let cell = view as? UITableViewCell {
                cell.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
            }
        }
        
        tableViewAdapter?.delegate = self
        tableViewAdapter?.dataSource = dataSource
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        eventHandler?.view(self, didSelectItemAt: indexPath)
    }
}
