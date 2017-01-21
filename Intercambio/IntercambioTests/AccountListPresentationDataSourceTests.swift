//
//  AccountListPresentationDataSourceTests.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 29.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import XCTest
import IntercambioCore
import CoreXMPP
import KeyChain
@testable import Intercambio

class AccountListPresentationDataSourceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        let keyChain = KeyChain(serviceName: "AccountListPresentationDataSourceTests")
        try! keyChain.removeAllItems()
    }
    
    override func tearDown() {
        let keyChain = KeyChain(serviceName: "AccountListPresentationDataSourceTests")
        try! keyChain.removeAllItems()
        super.tearDown()
    }
    
    // Tests
    
    func test() {
        let keyChain = KeyChain(serviceName: "AccountListPresentationDataSourceTests")
        let dataSource = AccountListDataSource(keyChain: keyChain)
        
        XCTAssertEqual(dataSource.numberOfSections(), 1)
        XCTAssertEqual(dataSource.numberOfItems(inSection: 0), 0)
        
        let jid = JID("romeo@example.com")!
        let item = KeyChainItem(identifier: jid.stringValue,
                                invisible: false,
                                options: [:])
        
        try! keyChain.add(item)
        
        XCTAssertEqual(dataSource.numberOfItems(inSection: 0), 1)
        
        if dataSource.item(at: IndexPath(item: 0, section: 0)) is AccountListViewModel {
            let uri = dataSource.accountURI(forItemAt: IndexPath(item: 0, section: 0))
            XCTAssertEqual(uri?.absoluteString, "xmpp://romeo@example.com")
        } else {
            XCTFail()
        }
    }
}
