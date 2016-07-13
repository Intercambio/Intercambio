//
//  SettingsModuleViewController.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 13.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import Fountain

class SettingsModuleViewController: UITableViewController, SettingsModuleUserInterface {
    
    internal var eventHandler: SettingsModuleEventHandler?
    
    var dataSource: FTDataSource? {
        didSet { tableViewAdapter?.dataSource = dataSource }
    }
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var tableViewAdapter: FTTableViewAdapter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(sender:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(safe(sender:)))
        
        tableView.allowsSelection = false
        tableView.register(UINib(nibName: "SettingsModuleURLCell", bundle: nil), forCellReuseIdentifier: "SettingsModuleURLCell")
        
        tableViewAdapter = FTTableViewAdapter(tableView: tableView)
        
        tableViewAdapter?.forRowsMatching(nil, useCellWithReuseIdentifier: "SettingsModuleURLCell") {
            (view, item, indexPath, dataSource) in
            if  let cell = view as? SettingsModuleURLCell,
                let formItem = item as? FormItem<URL> {
                cell.formItem = formItem
            }
        }
        
        tableViewAdapter?.delegate = self
        tableViewAdapter?.dataSource = dataSource
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        eventHandler?.loadSettings()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sectionItem = dataSource?.sectionItem(forSection: UInt(section)) as? FormSection {
            return sectionItem.title
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView,  titleForFooterInSection section: Int) -> String? {
        if let sectionItem = dataSource?.sectionItem(forSection: UInt(section)) as? FormSection {
            return sectionItem.instructions
        } else {
            return nil
        }
    }
    
    func cancel(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func safe(sender: AnyObject) {
        do {
            try eventHandler?.save()
            dismiss(animated: true, completion: nil)
        } catch {
            
        }
    }
}
