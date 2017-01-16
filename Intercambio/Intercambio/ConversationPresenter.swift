//
//  ConversationPresenter.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 21.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import IntercambioCore

class ConversationPresenter: NSObject, ConversationViewEventHandler {

    let archiveManager: ArchiveManager
    let accountManager: AccountManager
    init(archiveManager: ArchiveManager, accountManager: AccountManager) {
        self.archiveManager = archiveManager
        self.accountManager = accountManager
    }
    
    weak var view: ConversationView? {
        didSet {
            updateView()
        }
    }
    
    var showContactPicker: Bool = false
    
    var conversation: URL? {
        didSet {
            if account() == nil || counterpart() == nil {
                showContactPicker = true
            }
            updateDataSource()
            updateTitle()
            updateView()
        }
    }
    
    var dataSource: ConversationDataSource? {
        didSet {
            updateView()
        }
    }
    
    var title: String? {
        didSet {
            updateView()
        }
    }

    func shouldShowMenu(for itemAtIndexPtah: IndexPath) -> Bool {
        return dataSource?.shouldShowMenu(for: itemAtIndexPtah) ?? false
    }
    
    func canPerformAction(_ action: Selector, forItemAt indexPath: IndexPath) -> Bool {
        return dataSource?.canPerformAction(action, forItemAt: indexPath) ?? false
    }
    
    func performAction(_ action: Selector, forItemAt indexPath: IndexPath) {
        showContactPicker = false
        dataSource?.performAction(action, forItemAt: indexPath)
        updateView()
    }
    
    func setValue(_ value: Any, forItemAt indexPath: IndexPath) {
        showContactPicker = false
        dataSource?.setValue(value, forItemAt: indexPath)
        updateView()
    }
    
    private func updateView() {
        view?.dataSource = dataSource
        view?.title = title
        view?.isContactPickerVisible = showContactPicker
    }
    
    private func updateTitle() {
        if let jid = counterpart() {
            title = jid.bare().stringValue
        } else {
            title = nil
        }
    }
    
    private func updateDataSource() {
        guard
            let account = self.account(),
            let counterpart = self.counterpart()
            else {
                dataSource = nil
                return
        }
        
        if let dataSource = self.dataSource,
            dataSource.archive.account == account &&
            dataSource.counterpart == counterpart {
            return
        }

        archiveManager.archive(for: account, create: true) { (archive, error) in
            guard
                let newArchive = archive
                else {
                    NSLog("Failed to get the archive for '\(account)': \(error)")
                    return
            }
            
            DispatchQueue.main.async {
                do {
                    let conversationDataSource = ConversationDataSource(archive: newArchive, counterpart: counterpart)
                    try conversationDataSource.reload()
                    self.dataSource = conversationDataSource
                } catch {
                    NSLog("Failed to reload data soruce: \(error)")
                    self.dataSource = nil
                }
            }
        }
    }
    
    private func account() -> JID? {
        if let url = conversation {
            if let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true) {
                if components.scheme == "xmpp" {
                    if let host = components.host, let user = components.user {
                        let jid = JID(user: user, host: host, resource: nil)
                        if accountManager.accounts.contains(jid) {
                            return jid
                        }
                    }
                }
            }
        }
        return nil
    }
    
    private func counterpart() -> JID? {
        if let url = conversation {
            if url.scheme == "xmpp" {
                if let string = url.pathComponents.last {
                    return JID(string)
                }
            }
        }
        return nil
    }
}
