//
//  ConversationDataSource.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 21.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation
import MobileCoreServices

import Fountain
import PureXML
import XMPPFoundation
import XMPPMessageHub

extension ConversationViewModelType {
    fileprivate static func make(with type: MessageType) -> ConversationViewModelType {
        switch type {
        case .chat: return .chat
        case .error: return .error
        case .groupchat: return .groupchat
        case .headline: return .headline
        default: return .normal
        }
    }
}

class ConversationDataSource: NSObject, FTDataSource, FTPagingDataSource {

    let archive: Archive
    let counterpart: JID
    
    var pendingMessage: NSAttributedString?
    
    private let backingStore :FTMutableSet
    private let proxy: FTObserverProxy
    
    init(archive: Archive, counterpart: JID) {
        self.archive = archive
        self.counterpart = counterpart
        
        proxy = FTObserverProxy()
        
        let sortDescriptors = [
            NSSortDescriptor(key: nil, ascending: true, comparator: { (obj1, obj2) -> ComparisonResult in
                if let message1 = obj1 as? Message,
                   let message2 = obj2 as? Message {
                    if let date1 = message1.metadata.transmitted != nil ? message1.metadata.transmitted : message1.metadata.created,
                        let date2 = message2.metadata.transmitted != nil ? message2.metadata.transmitted : message2.metadata.created {
                        return date1.compare(date2)
                    } else {
                        return .orderedSame
                    }
                } else {
                    return .orderedSame
                }
            })
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
        let messages = try archive.conversation(with: counterpart)
        backingStore.performBatchUpdate { 
            self.backingStore.removeAllObjects()
            self.backingStore.addObjects(from: messages)
        }
    }
    
    private func participants() -> [JID] {
        return [self.archive.account, self.counterpart]
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
                let now = Date()
                let metadata = Metadata(created: now)
                let _ = try archive.insert(doc, metadata: metadata)
                resetPendingMessageText()
            } catch {
                NSLog("Failed to insert message into the archive: \(error)")
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
        let stanza = MessageStanza(from: archive.account, to: counterpart)
        stanza.type = .chat
        let _ = stanza.add(withName: "body", namespace: "jabber:client", content: pendingMessage?.string ?? "")
        return stanza.document
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
                    return ComposeViewModel(account: archive.account, attributedString: body)
                } else {
                    return ComposeViewModel(account: archive.account, attributedString: NSAttributedString())
                }
            } else {
                if let message = backingStore.item(at: indexPath) as? Message {
                    do {
                        let document = try archive.document(for: message.messageID)
                        let stanza = document.root as? MessageStanza
                        return ViewModel(message: message,
                                         stanza: stanza,
                                         editable: false)
                    } catch {
                        return ViewModel(message: message,
                                         stanza: nil,
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
    
    // FTPagingDataSource
    
    func hasItemsBeforeFirstItem() -> Bool {
        guard
            let incrementalArchive = archive as? IncrementalArchive
            else {
                return false
        }
        
        return incrementalArchive.canLoadMore
    }
    
    func loadMoreItems(beforeFirstItemCompletionHandler completionHandler: ((Bool, Error?) -> Swift.Void)!) {
        guard
            let incrementalArchive = archive as? IncrementalArchive
            else {
                completionHandler?(true, nil)
                return
        }
        
        incrementalArchive.loadMoreMessages { (error) in
            DispatchQueue.main.async {
                completionHandler?(error == nil, error)
            }
        }
    }
    
    func hasItemsAfterLastItem() -> Bool {
        return false
    }
    
    func loadMoreItems(afterLastItemCompletionHandler completionHandler: ((Bool, Error?) -> Swift.Void)!) {
        completionHandler?(true, nil)
    }

    // Direction
    
    private func direction(for message: Message) -> ConversationViewModelDirection {
        switch message.messageID.direction {
        case .inbound: return .inbound
        case .outbound: return .outbound
        }
    }
    
    // Notification Handling
    
    private func registerNotificationObservers() {
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(handleArchiveDidChange(notification:)),
                           name: Notification.Name.ArchiveDidChange,
                           object: archive)
    }
    
    private func unregisterNotificationObservers() {
        let center = NotificationCenter.default
        center.removeObserver(self, name: Notification.Name.ArchiveDidChange, object: archive)
    }
    
    @objc private func handleArchiveDidChange(notification: Notification) {
        DispatchQueue.main.async {
            let insertedOrUpdated = Set<Message>(self.insertedOrUpdatedMessages(in: notification))
            let removed = Set<Message>(self.removedMessages(in: notification))
            self.backingStore.performBatchUpdate {
                self.backingStore.union(insertedOrUpdated)
                self.backingStore.minus(removed)
            }
        }
    }

    private func insertedOrUpdatedMessages(in notification: Notification) -> [Message] {
        var messages: [Message] = []
        if let inserted = notification.userInfo?[InsertedMessagesKey] as? [Message] {
            let filtered = inserted.filter({ (message) -> Bool in
                return isConversationMessage(message.messageID)
            })
            messages.append(contentsOf: filtered)
        }
        if let updated = notification.userInfo?[UpdatedMessagesKey] as? [Message] {
            let filtered = updated.filter({ (message) -> Bool in
                return isConversationMessage(message.messageID)
            })
            messages.append(contentsOf: filtered)
        }
        return messages
    }
    
    private func removedMessages(in notification: Notification) -> [Message] {
        if let removed = notification.userInfo?[DeletedMessagesKey] as? [Message] {
            let filtered = removed.filter({ (message) -> Bool in
                return isConversationMessage(message.messageID)
            })
            return filtered
        } else {
            return []
        }
    }
    
    private func isConversationMessage(_ messageID: MessageID) -> Bool {
        return messageID.account == archive.account && messageID.counterpart == counterpart
    }
}

extension ConversationDataSource {
    class ViewModel : NSObject, ConversationViewModel {
        
        let message: Message
        let stanza: MessageStanza?
        let direction: ConversationViewModelDirection
        let editable: Bool
        
        init(message: Message, stanza: MessageStanza?, editable: Bool) {
            self.message = message
            self.stanza = stanza
            self.editable = editable
            switch message.messageID.type {
            case .error:
                self.direction = .undefined
            default:
                self.direction = message.messageID.direction == .inbound ? .inbound : .outbound
            }
        }
        
        var origin: URL? {
            let components = NSURLComponents()
            components.scheme = "xmpp"
            switch message.messageID.direction {
            case .inbound:
                components.path = "/\(message.messageID.counterpart.bare().stringValue)"
            case .outbound:
                components.path = "/\(message.messageID.account.bare().stringValue)"
            }
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
            guard let stanza = self.stanza else {
                return NSAttributedString()
            }
            
            if message.messageID.type == .error {
                let error = stanza.error
                return NSAttributedString(string: error?.localizedDescription ?? "")
            } else {
                let elements = stanza.nodes(forXPath: "x:body",
                                            usingNamespaces: ["x":"jabber:client"])
                if let body = elements.first as? PXElement {
                    return NSAttributedString(string: body.stringValue ?? "", attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body)])
                } else {
                    return NSAttributedString()
                }
            }
        }
        
        var type: ConversationViewModelType {
            if let string = body?.string, message.messageID.type != .error {
                let isOnlyEmoji = string.unicodeScalars.reduce(true) { result, codePoint in
                    codePoint.isEmoji
                }
                return isOnlyEmoji ? .emoji : ConversationViewModelType.make(with: message.messageID.type)
            } else {
                return ConversationViewModelType.make(with: message.messageID.type)
            }
        }
    }
}

extension ConversationDataSource {
    class ComposeViewModel: NSObject, ConversationViewModel {
        
        var direction: ConversationViewModelDirection = .outbound
        var type: ConversationViewModelType = .chat
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
