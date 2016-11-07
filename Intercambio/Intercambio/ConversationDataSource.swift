//
//  ConversationDataSource.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 21.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation
import Fountain
import XMPPMessageArchive
import PureXML
import MobileCoreServices

protocol ConversationMessageDB {
    func pendingMessages(withParticipants participants: [Any], includeTrashed: Bool) throws -> [Any]
    func messages(withParticipants participants: [Any], includeTrashed: Bool, before: Date?, limit: UInt) throws -> [Any]
    func document(for messageID: XMPPMessageID) throws -> PXDocument
    func message(with messageID: XMPPMessageID) throws -> XMPPMessage
    func insert(_ document: PXDocument) throws -> XMPPMessage
}

class ConversationDataSource: NSObject, FTDataSource {

    let db: ConversationMessageDB
    let account: JID
    let counterpart: JID
    
    var pendingMessage: NSAttributedString?
    
    private let backingStore :FTMutableSet
    private let proxy: FTObserverProxy
    
    init(db: ConversationMessageDB, account: JID, counterpart: JID) {
        self.db = db
        self.account = account.bare()
        self.counterpart = counterpart.bare()
        
        proxy = FTObserverProxy()
        
        let sortDescriptors = [
            NSSortDescriptor(key: "metadata", ascending: true, comparator: { (obj1, obj2) -> ComparisonResult in
                if let metadata1 = obj1 as? XMPPMessageMetadata,
                   let metadata2 = obj2 as? XMPPMessageMetadata {
                    if let date1 = metadata1.transmitted != nil ? metadata1.transmitted : metadata1.created,
                        let date2 = metadata2.transmitted != nil ? metadata2.transmitted : metadata2.created {
                        return date1.compare(date2)
                    } else {
                        return .orderedSame
                    }
                } else {
                    return .orderedSame
                }
            }),
            NSSortDescriptor(key: "messageID.ID", ascending: false)
        ]
        
        backingStore = FTMutableSet(sortDescriptors: sortDescriptors)
        super.init()
        proxy.object = self
        backingStore.addObserver(proxy)
        registerNotificationObservers()
    }
    
    deinit {
        unregisterNotificationObservers()
    }
    
    // Load Items
    
    func reload() throws {
        
        var messages: [XMPPMessage] = []
        messages.append(contentsOf: try pendingMessages())
        messages.append(contentsOf: try recentMessages())
        
        backingStore.performBatchUpdate { 
            self.backingStore.removeAllObjects()
            self.backingStore.addObjects(from: messages)
        }
    }
    
    private func pendingMessages() throws -> [XMPPMessage] {
        var messages: [XMPPMessage] = []
        for obj in try db.pendingMessages(withParticipants: participants(), includeTrashed: false) {
            if let message = obj as? XMPPMessage {
                messages.append(message)
            }
        }
        return messages
    }
    
    private func recentMessages() throws -> [XMPPMessage] {
        var messages: [XMPPMessage] = []
        for obj in try db.messages(withParticipants: participants(), includeTrashed: false, before: nil, limit: 0) {
            if let message = obj as? XMPPMessage {
                messages.append(message)
            }
        }
        return messages
    }
    
    private func participants() -> [JID] {
        return [self.account, self.counterpart]
    }
    
    // Performing actions
    
    func shouldShowMenu(for itemAtIndexPtah: IndexPath) -> Bool {
        return true
    }
    
    func canPerformAction(_ action: Selector, forItemAt indexPath: IndexPath) -> Bool {
        if action == #selector(UIResponder.copy(_:)) {
            return true
        }
        return false
    }
    
    func performAction(_ action: Selector, forItemAt indexPath: IndexPath) {
        if action == #selector(send) {
            if indexPath.section == 0 && indexPath.item == backingStore.count {
                send()
            }
        } else if action == #selector(UIResponder.copy(_:)) {
            copyMessage(forItemAt: indexPath)
        }
    }
    
    func send() {
        if let doc = messageDocument() {
            do {
                let _ = try db.insert(doc)
                resetPendingMessageText()
            } catch {
                
            }
        }
    }
    
    func copyMessage(forItemAt indexPath: IndexPath) {
        if let item = item(at: indexPath) as? ConversationViewModel {
            if let text = item.body {
                UIPasteboard.general.setValue(text.string, forPasteboardType: kUTTypeUTF8PlainText as String)
            }
        }
    }
    
    private func messageDocument() -> PXDocument? {
        let doc = PXDocument(elementName: "message", namespace: "jabber:client", prefix: nil)
        let _ = doc?.root.add(withName: "body", namespace: "jabber:client", content: pendingMessage?.string ?? "")
        doc?.root.setValue(self.account.stringValue, forAttribute: "from")
        doc?.root.setValue(self.counterpart.stringValue, forAttribute: "to")
        doc?.root.setValue(self.counterpart.stringValue, forAttribute: "type")
        doc?.root.setValue(NSUUID().uuidString, forAttribute: "id")
        return doc
    }
    
    private func resetPendingMessageText() {
        proxy.dataSourceWillChange(self)
        pendingMessage = nil
        let indexPath = IndexPath(item: backingStore.count, section: 0)
        proxy.dataSource(self, didChangeItemsAtIndexPaths: [indexPath])
        proxy.dataSourceDidChange(self)
    }
    
    // Modifying Content
    
    func setValue(_ value: Any?, forItemAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.item == backingStore.count {
            pendingMessage = value as? NSAttributedString
        }
    }
    
    // FTDataSource
    
    func numberOfSections() -> UInt {
        return 1
    }
    
    func numberOfItems(inSection section: UInt) -> UInt {
        if section == 0 {
            return UInt(backingStore.count) + UInt(1)
        } else {
            return 0
        }
    }
    
    func sectionItem(forSection section: UInt) -> Any! {
        return nil
    }
    
    func item(at indexPath: IndexPath!) -> Any! {
        if indexPath.section == 0 {
            if indexPath.item == backingStore.count {
                if let body = pendingMessage {
                    return ComposeViewModel(account: account, attributedString: body)
                } else {
                    return ComposeViewModel(account: account, attributedString: NSAttributedString())
                }
            } else {
                if let message = backingStore.item(at: indexPath) as? XMPPMessage {
                    do {
                        let document = try db.document(for: message.messageID)
                        return ViewModel(message: message,
                                         document: document,
                                         direction: direction(for: message),
                                         editable: false)
                    } catch {
                        return ViewModel(message: message,
                                         document: nil,
                                         direction: direction(for: message),
                                         editable: false)
                    }
                } else {
                    return nil
                }
            }
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

    // Direction
    
    private func direction(for message: XMPPMessage) -> ConversationViewModelDirection {
        if message.from.bare().isEqual(self.account.bare()) {
            return .outbound
        } else if message.from.bare().isEqual(self.counterpart.bare()) {
            return .inbound
        } else {
            return .undefined
        }
    }
    
    // Notification Handling
    
    private lazy var notificationObservers = [NSObjectProtocol]()
    
    private func registerNotificationObservers() {
        let center = NotificationCenter.default
        
        notificationObservers.append(center.addObserver(forName: NSNotification.Name(rawValue: XMPPMessageDBDidChange),
                                                        object: self.db,
                                                        queue: OperationQueue.main) { [weak self] (notification) in
                                                            self?.handleMessageDBDidChange(notification: notification)
        })
    }
    
    private func unregisterNotificationObservers() {
        let center = NotificationCenter.default
        for observer in notificationObservers {
            center.removeObserver(observer)
        }
        notificationObservers.removeAll()
    }
    
    private func handleMessageDBDidChange(notification: Notification) {
        let insertedOrUpdated = Set(insertedOrUpdatedMessages(in: notification))
        let removed = Set(removedMessages(in: notification))
        backingStore.performBatchUpdate {
            self.backingStore.union(insertedOrUpdated)
            self.backingStore.minus(removed)
        }
    }
    
    private func insertedOrUpdatedMessages(in notification: Notification) -> [XMPPMessage] {
        if let messageIDs = notification.userInfo?[XMPPInsertedOrUpdatedMessageIDsKey] as? Set<XMPPMessageID> {
            do {
                return try messageIDs.filter({ (messageID) -> Bool in
                    return isConversationMessage(messageID)
                }).map({ (messageID) -> XMPPMessage in
                    return try db.message(with: messageID)
                })
            } catch {
                return []
            }
        } else {
            return []
        }
    }
    
    private func removedMessages(in notification: Notification) -> [XMPPMessage] {
        if let messageIDs = notification.userInfo?[XMPPDeletedMessageIDsKey] as? Set<XMPPMessageID> {
            do {
                return try messageIDs.filter({ (messageID) -> Bool in
                    return isConversationMessage(messageID)
                }).map({ (messageID) -> XMPPMessage in
                    return try db.message(with: messageID)
                })
            } catch {
                return []
            }
        } else {
            return []
        }
    }
    
    private func isConversationMessage(_ messageID: XMPPMessageID) -> Bool {
        let participants = Set(self.participants())
        switch participants.count {
        case 1:
            return messageID.from.bare() == messageID.to.bare()
                && participants.contains(messageID.to.bare())
        case 2:
            return messageID.from.bare() != messageID.to.bare()
                && participants.contains(messageID.from.bare())
                && participants.contains(messageID.to.bare())
        default:
            return false
        }
    }
}

extension ConversationDataSource {
    class ViewModel : NSObject, ConversationViewModel {
        
        let message: XMPPMessage
        let document: PXDocument?
        let direction: ConversationViewModelDirection
        let editable: Bool
        
        init(message: XMPPMessage, document: PXDocument?, direction: ConversationViewModelDirection, editable: Bool) {
            self.message = message
            self.document = document
            self.direction = direction
            self.editable = editable
        }
        
        var origin: URL? {
            let components = NSURLComponents()
            components.scheme = "xmpp"
            components.path = "/\(message.from.bare().stringValue)"
            return components.url
        }
        
        var temporary: Bool {
            return message.metadata.transmitted == nil
        }
        
        var timestamp: Date? {
            if let date = message.metadata.transmitted != nil ? message.metadata.transmitted : message.metadata.created {
                return date
            } else {
                return Date.distantPast
            }
        }
        
        var body: NSAttributedString? {
            if let document = self.document {
                let elements = document.root.nodes(forXPath: "x:body",
                                                   usingNamespaces: ["x":"jabber:client"])
                if let body = elements?.first as? PXElement {
                    return NSAttributedString(string: body.stringValue, attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body)])
                }
            }
            return NSAttributedString()
        }
    }
}

extension ConversationDataSource {
    class ComposeViewModel: NSObject, ConversationViewModel {
        
        var direction: ConversationViewModelDirection = .outbound
        var editable: Bool = true
        var temporary: Bool = true
        var timestamp: Date?
        
        var origin: URL? {
            let components = NSURLComponents()
            components.scheme = "xmpp"
            components.path = "/\(account.bare().stringValue)"
            return components.url
        }
        
        var body: NSAttributedString?
        
        let account: JID
        
        init(account: JID, attributedString: NSAttributedString) {
            self.account = account
            self.body = attributedString
        }
    }
}
