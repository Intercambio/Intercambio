//
//  SettingsInteractor.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 12.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation
import IntercambioCore
import CoreXMPP

class SettingsInteractor : SettingsProvider {
    
    weak var presenter: SettingsOutput?
    
    let accountURI: URL?
    let identifier: String
    
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
    
    var settings: Settings {
        get {
            do {
                let item = try keyChain.item(jid: accountJID)
                return makeSettings(item.options)
            } catch {
                return Settings()
            }
        }
    }
    
    func update(settings: Settings) throws {
        var item = try keyChain.item(jid: accountJID)
        item = KeyChainItem(jid: item.jid, invisible: false, options: makeValues(settings))
        try keyChain.update(item)
        
    }
    
    // Settings <--> Options
    
    private func makeSettings(_ values: [AnyHashable : Any]) -> Settings {
        var settings = Settings()
        settings.websocketURL =  values[WebsocketStreamURLKey] as? URL
        return settings
    }
    
    private func makeValues(_ settings: Settings) -> [AnyHashable : Any] {
        var values = [AnyHashable : Any]()
        values[WebsocketStreamURLKey] = settings.websocketURL
        return values
    }
}
