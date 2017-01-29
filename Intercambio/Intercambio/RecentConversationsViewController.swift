//
//  RecentConversationsViewController.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 10.10.16.
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
import Fountain

public class RecentConversationsViewController: UITableViewController, RecentConversationsView {

    var presenter: RecentConversationsViewEventHandler?
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
        
        let isCollapsed: () -> Bool = { [weak self] () in
            return self?.splitViewController?.isCollapsed ?? false
        }
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
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
                cell.isChevronHidden = isCollapsed() == false
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
        presenter?.view(self, didSelectItemAt: indexPath)
    }
    
    @objc private func newConversation() -> Void {
        presenter?.newConversation()
    }
}
