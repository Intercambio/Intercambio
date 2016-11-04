//
//  SettingsDataSourceTests.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 04.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import XCTest
import IntercambioCore
import CoreXMPP
@testable import Intercambio

class SettingsDataSourceTests: XCTestCase {
    
    var keyChain: KeyChain {
        return KeyChain(named: "SettingsDataSourceTests")
    }
    
    override func setUp() {
        super.setUp()
        try! keyChain.clear()
        
        let jid = JID("juliet@example.com")!
        let options = [WebsocketStreamURLKey:URL(string: "https://ws.example.com")]
        let item = KeyChainItem(jid: jid,
                                invisible: false,
                                options: options)
        try! keyChain.add(item)
    }
    
    override func tearDown() {
        try! keyChain.clear()
        super.tearDown()
    }

    // Tests
    
    func testNonExistingAccount() {
        let jid = JID("romeo@example.com")!
        let dataSource = SettingsDataSource(accountJID: jid, keyChain: keyChain)
        
        XCTAssertThrowsError(try dataSource.reload())
        XCTAssertEqual(dataSource.numberOfSections(), 0)
    }
    
    func testExistingAccount() {
        let jid = JID("juliet@example.com")!
        let dataSource = SettingsDataSource(accountJID: jid, keyChain: keyChain)
        
        do {
            try dataSource.reload()
            XCTAssertEqual(dataSource.numberOfSections(), 3)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testGetAccount() {
        let jid = JID("juliet@example.com")!
        let dataSource = SettingsDataSource(accountJID: jid, keyChain: keyChain)
        
        do {
            try dataSource.reload()
            
            XCTAssertEqual(dataSource.numberOfItems(inSection: 0), 2)
            
            if let item = dataSource.item(at: IndexPath(item: 0, section: 0)) as? FormValueItem {
                XCTAssertEqual(item.title, jid.stringValue)
            } else {
                XCTFail("Expecting the item to be of type 'FormValueItem'.")
            }
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testGetWebsocketURL() {
        let jid = JID("juliet@example.com")!
        let dataSource = SettingsDataSource(accountJID: jid, keyChain: keyChain)
        
        do {
            try dataSource.reload()
            
            XCTAssertEqual(dataSource.numberOfItems(inSection: 1), 1)
            
            if let item = dataSource.item(at: IndexPath(item: 0, section: 1)) as? FormURLItem {
                XCTAssertEqual(item.url, URL(string: "https://ws.example.com"))
            } else {
                XCTFail("Expecting the item to be of type 'FormURLItem'.")
            }
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testSetWebsocketURL() {
        let jid = JID("juliet@example.com")!
        let dataSource = SettingsDataSource(accountJID: jid, keyChain: keyChain)
        
        do {
            try dataSource.reload()
            
            XCTAssertEqual(dataSource.numberOfItems(inSection: 1), 1)
            
            dataSource.setValue(URL(string: "https://ws.example.com/test"), forItemAt: IndexPath(item: 0, section: 1))
            
            if let item = dataSource.item(at: IndexPath(item: 0, section: 1)) as? FormURLItem {
                XCTAssertEqual(item.url, URL(string: "https://ws.example.com/test"))
            } else {
                XCTFail("Expecting the item to be of type 'FormURLItem'.")
            }
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testRemoveAccount() {
        let jid = JID("juliet@example.com")!
        let dataSource = SettingsDataSource(accountJID: jid, keyChain: keyChain)
        
        do {
            try dataSource.reload()
            
            XCTAssertEqual(dataSource.numberOfItems(inSection: 2), 1)
            
            dataSource.performAction(#selector(removeAccount), forItemAt: IndexPath(item: 0, section: 2))
            XCTAssertThrowsError(try keyChain.item(jid: jid))
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testSave() {
        let jid = JID("juliet@example.com")!
        let dataSource = SettingsDataSource(accountJID: jid, keyChain: keyChain)
        
        do {
            try dataSource.reload()
            
            dataSource.setValue(URL(string: "https://ws.example.com/test"), forItemAt: IndexPath(item: 0, section: 1))
            try dataSource.save()
            
            let item = try keyChain.item(jid: jid)
            XCTAssertNotNil(item)
            XCTAssertEqual(item.options[WebsocketStreamURLKey] as? URL, URL(string: "https://ws.example.com/test"))
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func removeAccount() throws {} // Just to have the selector
}
