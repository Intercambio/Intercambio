//
//  AccountListPresenterTests.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 29.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import XCTest
import IntercambioCore
import CoreXMPP
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
        let keyChain = KeyChain(named: "AccountModuleInteractorImplTests")
        try! keyChain.clear()
    }
    
    override func tearDown() {
        let keyChain = KeyChain(named: "AccountModuleInteractorImplTests")
        try! keyChain.clear()
        super.tearDown()
    }
    
    // Tests
    
    func testSetDataSource() {
        let keyChain = KeyChain(named: "AccountModuleInteractorImplTests")
        let presenter = AccountListPresenter(keyChain: keyChain, router: Router())
        
        let view = View()
        XCTAssertNil(view.dataSource)

        presenter.view = view
        XCTAssertNotNil(view.dataSource)
    }
    
    func testPresentAccount() {
        let keyChain = KeyChain(named: "AccountModuleInteractorImplTests")
        let jid = JID("romeo@example.com")!
        let item = KeyChainItem(jid: jid,
                                invisible: false,
                                options: [:])
        try! keyChain.add(item)
        
        let presenter = AccountListPresenter(keyChain: keyChain, router: Router())
        
        expectation(forNotification: "presentAccountUserInterface", object: presenter.router) { (n) -> Bool in true }
        
        if let account = presenter.dataSource.item(at: IndexPath(item: 0, section: 0)) as? AccountListPresentationModel {
            presenter.didSelect(account)
        } else {
            XCTFail()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testPresentNewAccount() {
        let keyChain = KeyChain(named: "AccountModuleInteractorImplTests")
        let presenter = AccountListPresenter(keyChain: keyChain, router: Router())
                
        expectation(forNotification: "presentNewAccountUserInterface", object: presenter.router) { (n) -> Bool in true }
        
        presenter.didTapNewAccount()

        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
