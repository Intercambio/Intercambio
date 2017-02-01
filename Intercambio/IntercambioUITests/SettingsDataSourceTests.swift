//
//  SettingsDataSourceTests.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 04.11.16.
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

import XCTest
import IntercambioCore
import CoreXMPP
import KeyChain
@testable import IntercambioUI

class SettingsDataSourceTests: XCTestCase {
    
    var keyChain: KeyChain {
        return KeyChain(serviceName: "SettingsDataSourceTests")
    }
    
    override func setUp() {
        super.setUp()
        try! keyChain.removeAllItems()
        
        let jid = JID("juliet@example.com")!
        let options = [WebsocketStreamURLKey: URL(string: "https://ws.example.com")!]
        let item = KeyChainItem(
            identifier: jid.stringValue,
            invisible: false,
            options: options
        )
        try! keyChain.add(item)
    }
    
    override func tearDown() {
        try! keyChain.removeAllItems()
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
            XCTAssertThrowsError(try keyChain.item(with: jid.stringValue))
            
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
            
            let item = try keyChain.item(with: jid.stringValue)
            XCTAssertNotNil(item)
            XCTAssertEqual(item.options[WebsocketStreamURLKey] as? URL, URL(string: "https://ws.example.com/test"))
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func removeAccount() throws {} // Just to have the selector
}
