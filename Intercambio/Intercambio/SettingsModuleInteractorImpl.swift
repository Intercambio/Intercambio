//
//  SettingsModuleInteractorImpl.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 12.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation
import IntercambioCore
import CoreXMPP

public class SettingsModuleInteractorImpl : SettingsModuleInteractor {
    
    internal weak var presenter: SettingsModulePresenter?
    
    public let accountURI: URL?
    public let identifier: String
    
    private let accountJID: JID
    private let keyChain: KeyChain
    
    init(accountJID: JID, keyChain: KeyChain) {
        self.accountJID = accountJID
        self.keyChain = keyChain
        self.identifier = accountJID.stringValue
        var components = URLComponents()
        components.scheme = "xmpp"
        components.host = accountJID.host
        components.user = accountJID.user
        self.accountURI = components.url
    }
    
    deinit {
        
    }
    
    public var settings: Settings {
        get {
            do {
                let item = try keyChain.item(jid: accountJID)
                return settings(item.options)
            } catch {
                return Settings()
            }
        }
    }
    
    public func update(settings: Settings) throws {
        var item = try keyChain.item(jid: accountJID)
        item = KeyChainItem(jid: item.jid, invisible: false, options: values(settings))
        try keyChain.update(item)
        
    }
    
    // Settings <--> Options
    
    private func settings(_ values: [NSObject : AnyObject]) -> Settings {
        var settings = Settings()
        settings.websocketURL =  values[WebsocketStreamURLKey] as? URL
        return settings
    }
    
    private func values(_ settings: Settings) -> [NSObject : AnyObject] {
        var values = [NSObject : AnyObject]()
        values[WebsocketStreamURLKey] = settings.websocketURL
        return values
    }
}
