//
//  SettingsViewController.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 13.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
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
