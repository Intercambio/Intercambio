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
@testable import Intercambio

class AccountListPresentationDataSourceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        let keyChain = KeyChain(named: "AccountModuleInteractorImplTests")
        try! keyChain.clear()
    }
    
    override func tearDown() {
        let keyChain = KeyChain(named: "AccountModuleInteractorImplTests")
        try! keyChain.clear()
        super.tearDown()
    }
    
    // Tests
    
    func test() {
        let keyChain = KeyChain(named: "AccountModuleInteractorImplTests")
        let dataSource = AccountListPresentationDataSource(keyChain: keyChain)
        
        XCTAssertEqual(dataSource.numberOfSections(), 1)
        XCTAssertEqual(dataSource.numberOfItems(inSection: 0), 0)
        
        let jid = JID("romeo@example.com")!
        let item = KeyChainItem(jid: jid,
                                invisible: false,
                                options: [:])
        
        try! keyChain.add(item)
        
        XCTAssertEqual(dataSource.numberOfItems(inSection: 0), 1)
        
        if let model = dataSource.item(at: IndexPath(item: 0, section: 0)) as? AccountListPresentationModel {
            XCTAssertEqual(model.identifier, "romeo@example.com")
            XCTAssertEqual(model.name, "romeo@example.com")
            XCTAssertEqual(model.accountURI?.absoluteString, "xmpp://romeo@example.com")
        } else {
            XCTFail()
        }
    }
}
