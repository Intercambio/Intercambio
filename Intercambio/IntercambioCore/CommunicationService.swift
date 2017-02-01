//
//  CommunicationService.swift
//  IntercambioCore
//
//  Created by Tobias Kraentzer on 17.01.17.
//  Copyright © 2017 Tobias Kräntzer.
//
//  This file is part of IntercambioCore.
//
//  IntercambioCore is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option)
//  any later version.
//
//  IntercambioCore is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
//  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along with
//  IntercambioCore. If not, see <http://www.gnu.org/licenses/>.
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
import KeyChain
import XMPPFoundation
import CoreXMPP
import XMPPMessageHub
import XMPPContactHub

@objc public protocol CommunicationServiceDelegate: class {
    func communicationService(_ communicationService: CommunicationService, needsPasswordForAccount accountURI: URL, completion: @escaping (String?) -> Void)
}

@objc public protocol CommunicationServiceDebugDelegate: CommunicationServiceDelegate {
    func communicationService(_ communicationService: CommunicationService, didReceive document: PXDocument)
    func communicationService(_ communicationService: CommunicationService, willSend document: PXDocument)
}

public class CommunicationService: NSObject, SASLMechanismDelegate, XMPPDispatcherDelegate, ConnectionHandler {
    
    public weak var delegate: CommunicationServiceDelegate? {
        didSet {
            if delegate is CommunicationServiceDebugDelegate {
                if let dispatcher = self.dispatcher as? XMPPDispatcherImpl {
                    dispatcher.delegate = self
                }
            }
        }
    }
    
    public let keyChain: KeyChain
    public let accountManager: AccountManager
    public let messageHub: MessageHub
    public let contactHub: ContactHub
    
    let dispatcher: Dispatcher
    
    private let accountManagerUpdater: AccountManagerUpdater
    private let accountCleanupHandler: AccountCleanupHandler
    
    public init(baseDirectory: URL, serviceName: String) {
        let dispatcher = XMPPDispatcherImpl()
        
        self.keyChain = KeyChain(serviceName: serviceName)
        self.accountManager = AccountManager(dispatcher: dispatcher)
        self.messageHub = MessageHub(dispatcher: dispatcher, directory: baseDirectory)
        self.contactHub = ContactHub(dispatcher: dispatcher, directory: baseDirectory)
        self.dispatcher = dispatcher
        self.accountManagerUpdater = AccountManagerUpdater(accountManager: accountManager, keyChain: keyChain)
        self.accountCleanupHandler = AccountCleanupHandler(keyChain: keyChain, messageHub: messageHub, contactHub: contactHub)
        super.init()
        self.accountManager.saslDelegate = self
        self.accountManagerUpdater.start()
        self.dispatcher.add(self)
    }
    
    public func loadRecentMessages(completion: ((Error?) -> (Void))?) {
        do {
            let group = DispatchGroup()
            let items = try keyChain.items()
            for item in items {
                if let account = JID(item.identifier) {
                    group.enter()
                    messageHub.archive(for: account)  { (archive, error) in
                        
                        if error != nil {
                            NSLog("Failed to get archive for '\(account)': \(error)")
                        }
                        
                        guard
                            let incrementalArchive = archive as? IncrementalArchive
                            else {
                                group.leave()
                                return
                        }
                        
                        incrementalArchive.loadRecentMessages { (error) in
                            if error != nil {
                                NSLog("Failed to load recent messages for '\(account)': \(error)")
                            }
                            group.leave()
                        }
                    }
                }
            }
            group.notify(queue: DispatchQueue.main) {
                completion?(nil)
            }
        } catch {
            completion?(error)
        }
    }
    
    // MARK: - SASLMechanismDelegate
    
    public func saslMechanismNeedsCredentials(_ mechanism: SASLMechanism!) {
        guard
            let account = mechanism.context as? JID,
            let plain = mechanism as? SASLMechanismPLAIN
            else {
                return
        }
        
        authenticate(plain, for: account)
    }
    
    private func authenticate(_ mechanism: SASLMechanismPLAIN, for account: JID) {
        do {
            let username = account.stringValue
            let password = try keyChain.passwordForItem(with: username)
            mechanism.authenticate(withUsername: username, password: password) { (success, error) in
                if success == false {
                    do {
                        try self.keyChain.setPassword(nil, forItemWith: username)
                    } catch {
                        NSLog("Failed to clear password: \(error)")
                    }
                }
            }
        } catch let error as NSError where error.domain == KeyChainErrorDomain && error.code == KeyChainErrorCode.noPassword.rawValue {
            let username = account.stringValue
            let url = makeURL(for: account)
            delegate?.communicationService(self, needsPasswordForAccount: url) { (password) in
                mechanism.authenticate(withUsername: username, password: password) { (success, error) in
                    if success == true {
                        do {
                            try self.keyChain.setPassword(password, forItemWith: username)
                        } catch {
                            NSLog("Failed to update password: \(error)")
                        }
                    }
                }
            }
        } catch {
            NSLog("Failed to authenticate: \(error)")
            mechanism.abort()
        }
    }
    
    private func makeURL(for account: JID) -> URL {
        var components = URLComponents()
        components.scheme = "xmpp"
        components.user = account.user
        components.host = account.host
        return components.url!
    }
    
    // MARK: - XMPPDispatcherDelegate
    
    public func dispatcher(_ dispatcher: Dispatcher, didReceive document: PXDocument) {
        guard
            let delegate = self.delegate as? CommunicationServiceDebugDelegate
            else {
                return
        }
        delegate.communicationService(self, didReceive: document)
    }
    
    public func dispatcher(_ dispatcher: Dispatcher, willSend document: PXDocument) {
        guard
            let delegate = self.delegate as? CommunicationServiceDebugDelegate
            else {
                return
        }
        delegate.communicationService(self, willSend: document)
    }
    
    // MARK: - ConnectionHandler
    
    public func didConnect(_ JID: JID, resumed: Bool, features: [Feature]?) {
        if resumed == false {
            sendInitialPresence(for: JID)
        }
    }
    
    public func didDisconnect(_ JID: JID) {
        
    }
    
    private func sendInitialPresence(for account: JID) {
        
        let stanza = PresenceStanza(from: account, to: nil)
        stanza.add(withName: "show", namespace: "jabber:client", content: "chat")
        stanza.add(withName: "priority", namespace: "jabber:client", content: "1")
        
        dispatcher.handlePresence(stanza) { (error) in
            if error != nil {
                NSLog("Failed to send initial presence for account '\(account)': \(error)")
            }
        }
    }
}
