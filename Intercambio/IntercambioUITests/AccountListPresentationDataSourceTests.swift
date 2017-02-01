//
//  AccountListPresentationDataSourceTests.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 29.07.16.
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
        let item = KeyChainItem(
            identifier: jid.stringValue,
            invisible: false,
            options: [:]
        )
        
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
