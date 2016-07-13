//
//  SettingsModuleInteractorImplTests.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 12.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import XCTest
import IntercambioCore
import CoreXMPP
@testable import Intercambio

class SettingsModuleInteractorImplTests: XCTestCase {

    override func setUp() {
        super.setUp()
        let keyChain = KeyChain(named: "SettingsModuleInteractorImplTests")
        try! keyChain.clear()
    }
    
    override func tearDown() {
        let keyChain = KeyChain(named: "SettingsModuleInteractorImplTests")
        try! keyChain.clear()
        super.tearDown()
    }
    
    // Tests
    
    func testNonExistingAccount() {
        let jid = JID("romeo@example.com")!
        
        let keyChain = KeyChain(named: "SettingsModuleInteractorImplTests")
        let interactor = SettingsModuleInteractorImpl(accountJID: jid,
                                                      keyChain: keyChain)
        
        XCTAssertNotNil(interactor.settings)
    }
    
    func testExistingAccount() {
        let jid = JID("romeo@example.com")!
        
        let keyChain = KeyChain(named: "SettingsModuleInteractorImplTests")
        let item = KeyChainItem(jid: jid,
                                invisible: false,
                                options: [:])
        try! keyChain.add(item)
        
        let interactor = SettingsModuleInteractorImpl(accountJID: jid,
                                                      keyChain: keyChain)
        
        XCTAssertNotNil(interactor.settings)
    }
    
    func testGettingSettings() {
        let jid = JID("romeo@example.com")!
        
        let keyChain = KeyChain(named: "SettingsModuleInteractorImplTests")
        let item = KeyChainItem(jid: jid,
                                invisible: false,
                                options: [WebsocketStreamURLKey: URL(string: "wws://example.com/xmpp")!])
        try! keyChain.add(item)
        
        let interactor = SettingsModuleInteractorImpl(accountJID: jid,
                                                      keyChain: keyChain)
        
        XCTAssertEqual(interactor.settings.websocketURL, URL(string: "wws://example.com/xmpp"))
    }
    
    func testUpdateSettings() {
        let jid = JID("romeo@example.com")!
        
        let keyChain = KeyChain(named: "SettingsModuleInteractorImplTests")
        var item = KeyChainItem(jid: jid,
                                invisible: false,
                                options: [:])
        try! keyChain.add(item)
        
        let interactor = SettingsModuleInteractorImpl(accountJID: jid,
                                                      keyChain: keyChain)
        
        XCTAssertNil(interactor.settings.websocketURL)
        
        var settings = Settings()
        settings.websocketURL = URL(string: "wws://example.com/ws/xmpp")
        
        try! interactor.update(settings: settings)
        
        item = try! keyChain.item(jid: jid)
        XCTAssertEqual(item.options[WebsocketStreamURLKey] as? URL, URL(string: "wws://example.com/ws/xmpp"))
    }
}
