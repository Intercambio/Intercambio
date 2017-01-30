//
//  RecentConversationsDataSource.swift
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


import Foundation
import Fountain
import IntercambioCore
import XMPPMessageHub
import XMPPFoundation
import PureXML
import Dispatch
import KeyChain

class RecentConversationsDataSource: NSObject, FTDataSource {
    
    private let keyChain: KeyChain
    private let messageHub: MessageHub
    private let backingStore :FTMutableSet
    private let proxy: FTObserverProxy
    private var numberOfAccounts: Int {
        return archives.count
    }
    
    init(keyChain: KeyChain, messageHub: MessageHub) {
        self.keyChain = keyChain
        self.messageHub = messageHub
        proxy = FTObserverProxy()
        backingStore = FTMutableSet(sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)])
        super.init()
        proxy.object = self
        backingStore.addObserver(proxy)
        registerNotificationObservers()
        loadArchives()
    }
    
    deinit {
        unregisterNotificationObservers()
    }
    
    // Load Items
    
    private func updateConversations() {
        do {
            let recentConversations = try conversations()
            backingStore.performBatchUpdate {
                self.backingStore.removeAllObjects()
                self.backingStore.addObjects(from: recentConversations)
            }
        } catch {
            NSLog("Failed to update conversations: \(error)")
        }
    }
    
    private func updateConversations(for account: JID) {
        do {
            let recentConversations = try conversations(for: account)
            backingStore.performBatchUpdate {
                for conversation in recentConversations {
                    if !self.backingStore.contains(conversation) {
                        self.backingStore.add(conversation)
                    }
                }
                for obj in self.backingStore.allObjects {
                    let conversation = obj as! Conversation
                    if conversation.account == account && recentConversations.contains(conversation) == false {
                        self.backingStore.remove(conversation)
                    }
                }
            }
        } catch {
            NSLog("Failed to update conversations: \(error)")
        }
    }
    
    private func conversations() throws -> [Conversation] {
        let accounts = accountJIDs()
        var conversations: [Conversation] = []
        for account in accounts {
            try conversations.append(contentsOf: self.conversations(for: account))
        }
        return conversations
    }
    
    private func conversations(for account: JID) throws -> [Conversation] {
        var conversations: [Conversation] = []
        let messages = try recentMessages(for: account)
        for message in messages {
            conversations.append(Conversation(message: message))
        }
        return conversations
    }
    
    private func accountJIDs() -> [JID] {
        do {
            var accountJIDs: [JID] = []
            for item in try keyChain.items() {
                if let account = JID(item.identifier) {
                    accountJIDs.append(account)
                }
            }
            return accountJIDs
        } catch {
            return []
        }
    }
    
    private func recentMessages(for account: JID) throws -> [Message] {
        guard
            let archive = archives[account]
            else { return [] }
        return try archive.recent()
    }
    
    // Conversation URL
    
    func conversationURI(forItemAt indexPtah: IndexPath) -> URL? {
        if let conversation = backingStore.item(at: indexPtah) as? Conversation {
            let accountJID = conversation.account
            let counterpartJID = conversation.counterpart
            
            // account
            var components = URLComponents()
            components.scheme = "xmpp"
            components.host = accountJID.host
            components.user = accountJID.user
            
            // counterpart
            components.path = "/\(counterpartJID.bare().stringValue)"
            
            return components.url
        } else {
            return nil
        }
    }
    
    // FTDataSource
    
    func numberOfSections() -> UInt {
        return backingStore.numberOfSections()
    }
    
    func numberOfItems(inSection section: UInt) -> UInt {
        return backingStore.numberOfItems(inSection: section)
    }
    
    func sectionItem(forSection section: UInt) -> Any! {
        return nil
    }
    
    func item(at indexPath: IndexPath!) -> Any! {
        if let conversation = backingStore.item(at: indexPath) as? Conversation {
            var viewModel: ViewModel
            do {
                if let document = try archives[conversation.account]?.document(for: conversation.message.messageID),
                    let stanza = document.root as? MessageStanza  {
                    viewModel = ViewModel(conversation, stanza: stanza)
                } else {
                    viewModel = ViewModel(conversation, stanza: nil)
                }
            } catch {
                viewModel = ViewModel(conversation, stanza: nil)
            }
            viewModel.showSubtitle = numberOfAccounts > 1
            return viewModel
        } else {
            return nil
        }
    }
    
    func observers() -> [Any]! {
        return proxy.observers()
    }
    
    func addObserver(_ observer: FTDataSourceObserver!) {
        proxy.addObserver(observer)
    }
    
    func removeObserver(_ observer: FTDataSourceObserver!) {
        proxy.removeObserver(observer)
    }
    
    // Archive Management
    
    private func loadArchives() {
        do {
            let items = try keyChain.items()
            for item in items {
                if let account = JID(item.identifier) {
                    addArchive(for: account)
                }
            }
        } catch {
            NSLog("Failed to load the archive: \(error)")
        }
    }
    
    var archives: [JID:Archive] = [:]
    
    private func addArchive(for account: JID) {
        messageHub.archive(for: account) { (archive, error) in
            DispatchQueue.main.async {
                self.archives[account] = archive
                self.updateConversations()
            }
        }
    }
    
    private func removeArchive(for account: JID) {
        archives[account] = nil
        updateConversations()
    }
    
    private func removeAllArchives() {
        archives.removeAll()
        updateConversations()
    }
    
    // Notification Handling
    
    private func registerNotificationObservers() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(handleKeyChainNotification(_:)), name: nil, object: keyChain)
        center.addObserver(self, selector: #selector(handleArchiveChangeNotification(_:)), name: Notification.Name.ArchiveDidChange, object: nil)
    }
    
    private func unregisterNotificationObservers() {
        let center = NotificationCenter.default
        center.removeObserver(self, name: nil, object: keyChain)
    }
    
    @objc private func handleKeyChainNotification(_ notification: Notification) {
        DispatchQueue.main.async {

            switch notification.name.rawValue {

            case KeyChainDidAddItemNotification:
                guard
                    let item = notification.userInfo?[KeyChainItemKey] as? KeyChainItem,
                    let account = JID(item.identifier)
                    else { return }
                self.addArchive(for: account)
                
            case KeyChainDidRemoveItemNotification:
                guard
                    let item = notification.userInfo?[KeyChainItemKey] as? KeyChainItem,
                    let account = JID(item.identifier)
                    else { return }
                self.removeArchive(for: account)
                
            case KeyChainDidRemoveAllItemsNotification:
                self.removeAllArchives()
                
            default:
                break
            }
        }
    }
    
    @objc private func handleArchiveChangeNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            guard
                let archive = notification.object as? Archive
                else {
                    return
            }

            if self.archives[archive.account] === archive {
                self.updateConversations(for: archive.account)
            }
        }
    }
}

extension RecentConversationsDataSource {
    @objc class Conversation : NSObject {

        let message: Message
        
        init(message: Message) {
            self.message = message
        }
        
        var account: JID {
            return message.messageID.account
        }
        
        var counterpart: JID {
            return message.messageID.counterpart
        }
        
        var date: Date {
            if let date = message.metadata.transmitted {
                return date
            } else if let date = message.metadata.created {
                return date
            } else {
                return Date()
            }
        }
        
        override var hash: Int {
            return account.hash ^ counterpart.hash ^ (Int)(date.timeIntervalSinceReferenceDate)
        }
        
        override func isEqual(_ object: Any?) -> Bool {
            if let other = object as? Conversation {
                return account.isEqual(other.account) && counterpart.isEqual(other.counterpart) && date == other.date
            } else {
                return false
            }
        }
    }
}

extension RecentConversationsDataSource {
    @objc class ViewModel : NSObject, RecentConversationsViewModel {
        
        var showSubtitle: Bool
        
        private let conversation: Conversation
        private let stanza: MessageStanza?

        init(_ conversation: Conversation, stanza: MessageStanza?) {
            showSubtitle = true
            self.conversation = conversation
            self.stanza = stanza
        }
        
        var type: RecentConversationsViewModelType {
            switch conversation.message.messageID.type {
            case .chat: return .chat
            case .error: return .error
            case .groupchat: return .groupchat
            case .headline: return .headline
            case .normal: return .normal
            }
        }
        
        var title: String? {
            return conversation.counterpart.stringValue
        }
        
        var subtitle: String? {
            if showSubtitle {
                return "via \(conversation.account.stringValue)"
            } else {
                return nil
            }
        }
        
        var body: String? {
            guard let stanza = self.stanza else {
                return String()
            }
            
            if type == .error {
                let error = stanza.error
                return error?.localizedDescription ?? ""
            } else {
                let elements = stanza.nodes(forXPath: "x:body", usingNamespaces: ["x":"jabber:client"])
                if let body = elements.first as? PXElement {
                    return body.stringValue
                } else {
                    return String()
                }
            }
        }
        
        var dateString: String? {
            let formatter = DateFormatter()
            formatter.doesRelativeDateFormatting = true
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            return formatter.string(from: conversation.date)
        }
        
        var avatarImage: UIImage? {
            return nil
        }
        
        var unread: Bool {
            return conversation.message.metadata.read == nil
        }
    }
}
