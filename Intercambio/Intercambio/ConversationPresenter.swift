//
//  ConversationPresenter.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 21.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import IntercambioCore

class ConversationPresenter: NSObject, ConversationViewEventHandler, ContactPickerViewControllerDelegate {

    let db: ConversationMessageDB
    init(db: ConversationMessageDB) {
        self.db = db
    }
    
    weak var view: ConversationView? {
        didSet {
            updateView()
        }
    }
    
    var conversation: URL? {
        didSet {
            updateDataSource()
            updateTitle()
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
        view?.isContactPickerVisible = false
        dataSource?.performAction(action, forItemAt: indexPath)
    }
    
    func setValue(_ value: Any, forItemAt indexPath: IndexPath) {
        view?.isContactPickerVisible = false
        dataSource?.setValue(value, forItemAt: indexPath)
    }
    
    private func updateView() {
        view?.dataSource = dataSource
        view?.title = title
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
                        return JID(user: user, host: host, resource: nil)
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
    
    // ContactPickerViewControllerDelegate
    
    func contactPicker(_ picker: ContactPickerViewController, didSelect uri: URL?) {
        conversation = uri
    }
}
