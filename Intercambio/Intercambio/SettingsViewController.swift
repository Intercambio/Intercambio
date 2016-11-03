//
//  SettingsViewController.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 13.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import Fountain

public class SettingsViewController: UITableViewController, SettingsView {
    
    var eventHandler: SettingsViewEventHandler?
    
    var identifier: String? {
        didSet {
            navigationItem.prompt = identifier
        }
    }
    
    var dataSource: FTDataSource? {
        didSet { tableViewAdapter?.dataSource = dataSource }
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
        navigationItem.prompt = identifier

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(sender:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save(sender:)))
        
        tableView.allowsSelection = false
        tableView.register(UINib(nibName: "FormItemURLCell", bundle: nil), forCellReuseIdentifier: "FormItemURLCell")
        
        tableViewAdapter = FTTableViewAdapter(tableView: tableView)
        
        tableViewAdapter?.forRowsMatching(nil, useCellWithReuseIdentifier: "FormItemURLCell") {
            (view, item, indexPath, dataSource) in
            if  let cell = view as? FormItemURLCell,
                let formItem = item as? FormItem<URL> {
                cell.formItem = formItem
            }
        }
        
        tableViewAdapter?.delegate = self
        tableViewAdapter?.dataSource = dataSource
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        eventHandler?.loadSettings()
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
    
    func cancel(sender: AnyObject) {
        eventHandler?.cancel()
    }
    
    func save(sender: AnyObject) {
        do {
            try eventHandler?.save()
        } catch {
            
        }
    }
}
