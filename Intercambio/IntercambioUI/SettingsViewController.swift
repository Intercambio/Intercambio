//
//  SettingsViewController.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 13.07.16.
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

public class SettingsViewController: UITableViewController, UITableViewDelegateCellAction, SettingsView {
    
    var presenter: SettingsViewEventHandler?
    
    var dataSource: FTDataSource? {
        didSet {
            tableViewAdapter?.dataSource = dataSource
        }
    }
    
    public init() {
        super.init(style: .grouped)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var tableViewAdapter: FTTableViewAdapter?
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = NSLocalizedString("Settings", comment: "")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(sender:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save(sender:)))
        
        tableView.allowsSelection = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 45
        
        tableViewAdapter = FTTableViewAdapter(tableView: tableView)
        
        tableView.register(FormValueItemCell.self, forCellReuseIdentifier: "FormValueItemCell")
        tableViewAdapter?.forRowsMatching(FormValueItemCell.predicate,
                                          useCellWithReuseIdentifier: "FormValueItemCell")
        { (view, item, indexPath, dataSource) in
            if  let cell = view as? FormValueItemCell,
                let formItem = item as? FormValueItem {
                cell.item = formItem
            }
        }
        
        tableView.register(FormTextItemCell.self, forCellReuseIdentifier: "FormTextItemCell")
        tableViewAdapter?.forRowsMatching(FormTextItemCell.predicate,
                                          useCellWithReuseIdentifier: "FormTextItemCell")
        { (view, item, indexPath, dataSource) in
            if  let cell = view as? FormTextItemCell,
                let formItem = item as? FormTextItem {
                cell.item = formItem
            }
        }
        
        tableView.register(FormURLItemCell.self, forCellReuseIdentifier: "FormURLItemCell")
        tableViewAdapter?.forRowsMatching(FormURLItemCell.predicate,
                                          useCellWithReuseIdentifier: "FormURLItemCell")
        { (view, item, indexPath, dataSource) in
            if  let cell = view as? FormURLItemCell,
                let formItem = item as? FormURLItem {
                cell.item = formItem
            }
        }
        
        tableView.register(FormButtonItemCell.self, forCellReuseIdentifier: "FormButtonItemCell")
        tableViewAdapter?.forRowsMatching(FormButtonItemCell.predicate,
                                          useCellWithReuseIdentifier: "FormButtonItemCell")
        { (view, item, indexPath, dataSource) in
            if  let cell = view as? FormButtonItemCell,
                let formItem = item as? FormButtonItem {
                cell.item = formItem
            }
        }

        tableViewAdapter?.delegate = self
        tableViewAdapter?.dataSource = dataSource
    }
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sectionItem = dataSource?.sectionItem(forSection: UInt(section)) as? FormSection {
            return sectionItem.title
        } else {
            return nil
        }
    }
    
    public override func tableView(_ tableView: UITableView,  titleForFooterInSection section: Int) -> String? {
        if let sectionItem = dataSource?.sectionItem(forSection: UInt(section)) as? FormSection {
            return sectionItem.instructions
        } else {
            return nil
        }
    }
    
    public func tableView(_ tableView: UITableView, setValue value: Any?, forRowAt indexPath: IndexPath) {
        presenter?.setValue(value, forItemAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        presenter?.performAction(action, forItemAt: indexPath)
    }
    
    func cancel(sender: AnyObject) {
        if let responder = view.firstResponder() {
            responder.resignFirstResponder()
        }
        presenter?.cancel()
    }
    
    func save(sender: AnyObject) {
        if let responder = view.firstResponder() {
            responder.resignFirstResponder()
        }
        presenter?.save()
    }
}
