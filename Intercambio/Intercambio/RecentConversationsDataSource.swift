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
import XMPPMessageArchive
import PureXML
import Dispatch

protocol RecentConversationsMessageDB {
    func recentMessagesIncludeTrashed(_ includeTrashed: Bool) throws -> [Any]
    func document(for messageID: XMPPMessageID) throws -> PXDocument
}

class RecentConversationsDataSource: NSObject, FTDataSource {
    
    private let keyChain: KeyChain
    private let db: RecentConversationsMessageDB
    private let backingStore :FTMutableSet
    private let proxy: FTObserverProxy
    private var numberOfAccounts: Int
    
    init(keyChain: KeyChain, db: RecentConversationsMessageDB) {
        self.keyChain = keyChain
        self.db = db
        numberOfAccounts = 0
        proxy = FTObserverProxy()
        backingStore = FTMutableSet(sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)])
        super.init()
        proxy.object = self
        backingStore.addObserver(proxy)
        registerNotificationObservers()
        loadItems()
    }
    
    deinit {
        unregisterNotificationObservers()
    }
    
    // Load Items
    
    private func loadItems() {
        
        let currentNumberOfAccounts = numberOfAccounts
        numberOfAccounts = accountJIDs().count
        let needsReoad = numberOfAccounts != currentNumberOfAccounts
        
        backingStore.performBatchUpdate {
            let recentConversations = self.conversations()
            
            if needsReoad {
                self.backingStore.removeAllObjects()
                self.backingStore.addObjects(from: recentConversations)
            } else {
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
        }
    }
    
    private func conversations() -> [Conversation] {
        let accounts = accountJIDs()
        let messages = recentMessages()
        var conversations: [Conversation] = []
        for message in messages {
            // outbound
            if accounts.contains(message.from.bare()) {
                conversations.append(Conversation(message: message, direction: .outbound))
            }
            // inbound
            if accounts.contains(message.to.bare()) {
                conversations.append(Conversation(message: message, direction: .inbound))
            }
        }
        return conversations
    }
    
    private func accountJIDs() -> [JID] {
        do {
            var accountJIDs: [JID] = []
            for i in try keyChain.fetch() {
                if let item = i as? KeyChainItem {
                    accountJIDs.append(item.jid)
                }
            }
            return accountJIDs
        } catch {
            return []
        }
    }
    
    private func recentMessages() -> [XMPPMessage] {
        do {
            var messages: [XMPPMessage] = []
            for item in try self.db.recentMessagesIncludeTrashed(false) {
                if let message = item as? XMPPMessage {
                    messages.append(message)
                }
            }
            return messages
        } catch {
            return []
        }
    }
    
    // Conversation URL
    
    func conversationURI(at indexPtah: IndexPath) -> URL? {
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
                let document = try db.document(for: conversation.message.messageID)
                viewModel = ViewModel(conversation, document: document)
            } catch {
                viewModel = ViewModel(conversation, document: nil)
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
    
    // Notification Handling
    
    private lazy var notificationObservers = [NSObjectProtocol]()
    
    private func registerNotificationObservers() {
        let center = NotificationCenter.default
        
        // KeyChain
        
        notificationObservers.append(center.addObserver(forName: NSNotification.Name(rawValue: KeyChainDidAddItemNotification),
                                                        object: keyChain,
                                                        queue: OperationQueue.main) { [weak self] (notification) in
                                                            self?.loadItems()
        })
        
        notificationObservers.append(center.addObserver(forName: NSNotification.Name(rawValue: KeyChainDidRemoveItemNotification),
                                                        object: keyChain,
                                                        queue: OperationQueue.main) { [weak self] (notification) in
                                                            self?.loadItems()
        })
        
        notificationObservers.append(center.addObserver(forName: NSNotification.Name(rawValue: KeyChainDidClearNotification),
                                                        object: keyChain,
                                                        queue: OperationQueue.main) { [weak self] (notification) in
                                                            self?.loadItems()
        })
        
        // MessageDB
        
        notificationObservers.append(center.addObserver(forName: NSNotification.Name(rawValue: XMPPMessageDBDidChange),
                                                        object: self.db,
                                                        queue: OperationQueue.main) { [weak self] (notifcation) in
                                                            self?.loadItems()
        })
    }
    
    private func unregisterNotificationObservers() {
        let center = NotificationCenter.default
        for observer in notificationObservers {
            center.removeObserver(observer)
        }
        notificationObservers.removeAll()
    }
}

extension RecentConversationsDataSource {
    @objc class Conversation : NSObject {

        enum Direction {
            case inbound
            case outbound
        }
        
        let message: XMPPMessage
        let direction: Direction
        
        init(message: XMPPMessage, direction: Direction) {
            self.message = message
            self.direction = direction
        }
        
        var account: JID {
            switch direction {
            case .inbound:
                return message.to.bare()
            case .outbound:
                return message.from.bare()
            }
        }
        
        var counterpart: JID {
            switch direction {
            case .inbound:
                return message.from.bare()
            case .outbound:
                return message.to.bare()
            }
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
            return self.account.hash ^ self.counterpart.hash ^ (Int)(self.date.timeIntervalSinceReferenceDate)
        }
        
        override func isEqual(_ object: Any?) -> Bool {
            if let other = object as? Conversation {
                return self.account.isEqual(other.account) && self.counterpart.isEqual(other.counterpart) && self.date == other.date
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
        private let document: PXDocument?

        init(_ conversation: Conversation, document: PXDocument?) {
            showSubtitle = true
            self.conversation = conversation
            self.document = document
        }
        
        var title: String? {
            return self.conversation.counterpart.stringValue
        }
        
        var subtitle: String? {
            if showSubtitle {
                return "via \(self.conversation.account.stringValue)"
            } else {
                return nil
            }
        }
        
        var body: String? {
            if let document = self.document {
                let elements = document.root.nodes(forXPath: "x:body",
                                                   usingNamespaces: ["x":"jabber:client"])
                if let body = elements?.first as? PXElement {
                    return body.stringValue
                }
            }
            return nil
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
