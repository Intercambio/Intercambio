//
//  RecentConversationsDataSource.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 10.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
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
    private let archiveManager: ArchiveManager
    private let backingStore :FTMutableSet
    private let proxy: FTObserverProxy
    private var numberOfAccounts: Int
    
    init(keyChain: KeyChain, archiveManager: ArchiveManager) {
        self.keyChain = keyChain
        self.archiveManager = archiveManager
        numberOfAccounts = 0
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
                for conversation in recentConversations {
                    if !self.backingStore.contains(conversation) {
                        self.backingStore.add(conversation)
                    }
                }
                for conversation in self.backingStore.allObjects {
                    if !recentConversations.contains(conversation as! RecentConversationsDataSource.Conversation) {
                        self.backingStore.remove(conversation)
                    }
                }
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
            let archive = archvies[account]
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
                if let document = try archvies[conversation.account]?.document(for: conversation.message.messageID),
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
    
    var archvies: [JID:Archive] = [:]
    
    private func addArchive(for account: JID) {
        archiveManager.archive(for: account, create: true) { (archive, error) in
            self.archvies[account] = archive
            self.updateConversations(for: account)
        }
    }
    
    private func removeArchive(for account: JID) {
        archvies[account] = nil
        updateConversations(for: account)
    }
    
    private func removeAllArchives() {
        archvies.removeAll()
        updateConversations()
    }
    
    // Notification Handling
    
    private func registerNotificationObservers() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(handleKeyChainNotification(_:)), name: nil, object: keyChain)
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
                if let body = elements?.first as? PXElement {
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
