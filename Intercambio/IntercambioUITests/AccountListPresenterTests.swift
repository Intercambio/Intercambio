//
//  AccountListPresenterTests.swift
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
import KeyChain
import IntercambioCore
import CoreXMPP
import Fountain
@testable import IntercambioUI

class AccountListPresenterTests: XCTestCase {
    
    class Router: AccountListRouter {
        func presentNewAccountUserInterface() {
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "presentNewAccountUserInterface"),
                object: self
            )
        }
        func presentAccountUserInterface(for accountURI: URL) {
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "presentAccountUserInterface"),
                object: self,
                userInfo: ["uri": accountURI]
            )
        }
    }
    
    class View: AccountListView {
        var dataSource: FTDataSource?
    }
    
    override func setUp() {
        super.setUp()
        let keyChain = KeyChain(serviceName: "AccountListPresenterTests")
        try! keyChain.removeAllItems()
    }
    
    override func tearDown() {
        let keyChain = KeyChain(serviceName: "AccountListPresenterTests")
        try! keyChain.removeAllItems()
        super.tearDown()
    }
    
    // Tests
    
    func testSetDataSource() {
        let keyChain = KeyChain(serviceName: "AccountListPresenterTests")
        let presenter = AccountListPresenter(keyChain: keyChain)
        presenter.router = Router()
        
        let view = View()
        XCTAssertNil(view.dataSource)
        
        presenter.view = view
        XCTAssertNotNil(view.dataSource)
    }
    
    func testPresentAccount() {
        let view = View()
        
        let keyChain = KeyChain(serviceName: "AccountListPresenterTests")
        let jid = JID("romeo@example.com")!
        let item = KeyChainItem(
            identifier: jid.stringValue,
            invisible: false,
            options: [:]
        )
        try! keyChain.add(item)
        
        let presenter = AccountListPresenter(keyChain: keyChain)
        presenter.router = Router()
        
        expectation(forNotification: "presentAccountUserInterface", object: presenter.router) { (_) -> Bool in true }
        
        if presenter.dataSource.item(at: IndexPath(item: 0, section: 0)) is AccountListViewModel {
            presenter.view(view, didSelectItemAt: IndexPath(item: 0, section: 0))
        } else {
            XCTFail()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testPresentNewAccount() {
        let keyChain = KeyChain(serviceName: "AccountListPresenterTests")
        let presenter = AccountListPresenter(keyChain: keyChain)
        presenter.router = Router()
        
        expectation(forNotification: "presentNewAccountUserInterface", object: presenter.router) { (_) -> Bool in true }
        
        presenter.addAccount()
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
