//
//  AccountListPresenterTests.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 29.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import XCTest
import KeyChain
import IntercambioCore
import CoreXMPP
import Fountain
@testable import Intercambio

class AccountListPresenterTests: XCTestCase {
    
    class Router : AccountListRouter {
        func presentNewAccountUserInterface() {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "presentNewAccountUserInterface"),
                                            object: self)
        }
        func presentAccountUserInterface(for accountURI: URL) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "presentAccountUserInterface"),
                                            object: self,
                                            userInfo: ["uri": accountURI])
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
        let item = KeyChainItem(identifier: jid.stringValue,
                                invisible: false,
                                options: [:])
        try! keyChain.add(item)
        
        let presenter = AccountListPresenter(keyChain: keyChain)
        presenter.router = Router()
        
        expectation(forNotification: "presentAccountUserInterface", object: presenter.router) { (n) -> Bool in true }
        
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
                
        expectation(forNotification: "presentNewAccountUserInterface", object: presenter.router) { (n) -> Bool in true }
        
        presenter.addAccount()

        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
