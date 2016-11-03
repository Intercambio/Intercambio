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

    let db: ConversationMessageDB
    let accountManager: AccountManager
    init(db: ConversationMessageDB, accountManager: AccountManager) {
        self.db = db
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
        if let account = account(),
           let counterpart = counterpart() {
            do {
                let conversationDataSource = ConversationDataSource(db: db, account: account, counterpart: counterpart)
                try conversationDataSource.reload()
                dataSource = conversationDataSource
            } catch {
                dataSource = nil
            }
        } else {
            dataSource = nil
        }
    }
    
    private func account() -> JID? {
        if let url = conversation {
            if let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true) {
                if components.scheme == "xmpp" {
                    if let host = components.host, let user = components.user {
                        if let jid = JID(user: user, host: host, resource: nil) {
                            if accountManager.accounts.contains(jid) {
                                return jid
                            }
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
