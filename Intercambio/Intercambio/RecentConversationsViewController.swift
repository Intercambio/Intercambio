//
//  RecentConversationsViewController.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 10.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import Fountain

public class RecentConversationsViewController: UITableViewController, RecentConversationsView {

    var eventHandler: RecentConversationsViewEventHandler?
    var dataSource: FTDataSource? {
        didSet {
            tableViewAdapter?.dataSource = dataSource
        }
    }
    
    private var tableViewAdapter: FTTableViewAdapter?
    
    public init() {
        super.init(style: .plain)
        title = NSLocalizedString("Conversations", comment: "")
        tabBarItem = UITabBarItem(title: NSLocalizedString("Conversations", comment: ""),
                                  image: #imageLiteral(resourceName: "906-chat-3"),
                                  selectedImage: #imageLiteral(resourceName: "906-chat-3-selected"))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(newConversation))
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        tableViewAdapter = FTTableViewAdapter(tableView: tableView)
        tableViewAdapter?.rowAnimation = .fade
        
        tableView.register(UINib(nibName: "RecentConversationsCell", bundle: nil), forCellReuseIdentifier: "conversation")
        tableViewAdapter?.forRowsMatching(nil, useCellWithReuseIdentifier: "conversation") {
            (view, item, indexPath, dataSource) in
            if  let cell = view as? RecentConversationsCell,
                let viewModel = item as? RecentConversationsViewModel {
                cell.viewModel = viewModel
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
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        eventHandler?.view(self, didSelectItemAt: indexPath)
    }
    
    @objc private func newConversation() -> Void {
        eventHandler?.newConversation()
    }
}
