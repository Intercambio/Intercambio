//
//  ConversationPresenter.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 21.10.16.
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
import XMPPFoundation
import CoreXMPP
import XMPPMessageHub

class ConversationPresenter: NSObject, ConversationViewEventHandler {
    
    let messageHub: MessageHub
    let accountManager: AccountManager
    init(messageHub: MessageHub, accountManager: AccountManager) {
        self.messageHub = messageHub
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
        
        messageHub.archive(for: account) { archive, error in
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
