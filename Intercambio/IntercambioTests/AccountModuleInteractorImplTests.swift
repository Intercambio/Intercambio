//
//  AccountModuleInteractorImplTests.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 01.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import XCTest
import IntercambioCore
import CoreXMPP
@testable import Intercambio

class AccountModuleInteractorImplTests : XCTestCase {
    
    static var accountInfo: TestAccountInfo?
    
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
    
    func testNonExistingAccount() {
        let jid = JID("romeo@example.com")!
        
        let keyChain = KeyChain(named: "AccountModuleInteractorImplTests")
        let accountManager = TestAccountManager()
        let interactor = AccountModuleInteractorImpl(accountJID: jid,
                                                       keyChain: keyChain,
                                                       accountManager: accountManager)
        
        XCTAssertNil(interactor.account)
    }
    
    func testExistingAccount(){
        let jid = JID("romeo@example.com")!
        
        let keyChain = KeyChain(named: "AccountModuleInteractorImplTests")
        let item = KeyChainItem(jid: jid,
                                invisible: false,
                                options: [:])
        try! keyChain.add(item)
        
        let accountManager = TestAccountManager()
        let interactor = AccountModuleInteractorImpl(accountJID: jid,
                                                       keyChain: keyChain,
                                                       accountManager: accountManager)
        
        XCTAssertEqual(interactor.account?.identifier, jid.stringValue)
    }
    
    func testUpdateAccountViaKeyChain() {
        let jid = JID("romeo@example.com")!
        
        let keyChain = KeyChain(named: "AccountModuleInteractorImplTests")
        let accountManager = TestAccountManager()
        let interactor = AccountModuleInteractorImpl(accountJID: jid,
                                                       keyChain: keyChain,
                                                       accountManager: accountManager)
        
        XCTAssertNil(interactor.account)
        
        self.expectation(forNotification: AccountModuleInteractorDidUpdateAccount.rawValue,
                         object: interactor) {
            (notification)->Bool in true
        }
        
        let item = KeyChainItem(jid: jid, invisible: false, options: [:])
        try! keyChain.add(item)
        
        self.waitForExpectations(timeout: 1.0, handler: nil)
        
        XCTAssertEqual(interactor.account?.identifier, jid.stringValue)
    }
    
    func testUpdateAccountViaAccountManager() {
        let jid = JID("romeo@example.com")!
        
        let keyChain = KeyChain(named: "AccountModuleInteractorImplTests")
        let item = KeyChainItem(jid: jid, invisible: false, options: [:])
        try! keyChain.add(item)
        
        let accountManager = TestAccountManager()
        let interactor = AccountModuleInteractorImpl(accountJID: jid,
                                                       keyChain: keyChain,
                                                       accountManager: accountManager)
        
        XCTAssertEqual(interactor.account?.state, AccountConnectionState.disconnected)
        
        self.expectation(forNotification: AccountModuleInteractorDidUpdateAccount.rawValue,
                         object: interactor) {
            (notification)->Bool in true
        }
        
        AccountModuleInteractorImplTests.accountInfo = TestAccountInfo(state: .connected)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: AccountManagerDidChangeAccount),
                                          object: accountManager,
                                          userInfo: [AccountManagerAccountJIDKey: jid,
                                                     AccountManagerAccountInfoKey: AccountModuleInteractorImplTests.accountInfo!])
        
        self.waitForExpectations(timeout: 1.0, handler: nil)
        
        XCTAssertEqual(interactor.account?.state, AccountConnectionState.connected)
    }
    
    func testEnableAccount() {
        let jid = JID("romeo@example.com")!
        
        let keyChain = KeyChain(named: "AccountModuleInteractorImplTests")
        var item = KeyChainItem(jid: jid, invisible: true, options: [:])
        try! keyChain.add(item)
        
        let accountManager = TestAccountManager()
        let interactor = AccountModuleInteractorImpl(accountJID: jid,
                                                       keyChain: keyChain,
                                                       accountManager: accountManager)
        
        self.expectation(forNotification: KeyChainDidUpdateItemNotification,
                         object: keyChain,
                         handler: { (notification)->Bool in
                            if let userInfo = notification.userInfo,
                            let item = userInfo[KeyChainItemKey] as? KeyChainItem {
                                if jid == item.jid {
                                    return true
                                }
                            }
                            return false
        })
        
        try! interactor.enable()
        
        self.waitForExpectations(timeout: 1.0, handler: nil)
        
        item = try! keyChain.item(jid: jid)
        XCTAssertFalse(item.invisible)
    }
    
    func testDisableAccount() {
        let jid = JID("romeo@example.com")!
        
        let keyChain = KeyChain(named: "AccountModuleInteractorImplTests")
        var item = KeyChainItem(jid: jid, invisible: false, options: [:])
        try! keyChain.add(item)
        
        let accountManager = TestAccountManager()
        let interactor = AccountModuleInteractorImpl(accountJID: jid,
                                                       keyChain: keyChain,
                                                       accountManager: accountManager)
        
        self.expectation(forNotification: KeyChainDidUpdateItemNotification,
                         object: keyChain,
                         handler: { (notification)->Bool in
                            if let userInfo = notification.userInfo,
                            let item = userInfo[KeyChainItemKey] as? KeyChainItem {
                                if jid == item.jid {
                                    return true
                                }
                            }
                            return false
        })
        
        try! interactor.disable()
        
        self.waitForExpectations(timeout: 1.0, handler: nil)
        
        item = try! keyChain.item(jid: jid)
        XCTAssertTrue(item.invisible)
    }
    
    func testUpdateAccount() {
        let jid = JID("romeo@example.com")!
        
        let keyChain = KeyChain(named: "AccountModuleInteractorImplTests")
        var item = KeyChainItem(jid: jid, invisible: false, options: [:])
        try! keyChain.add(item)
        
        let accountManager = TestAccountManager()
        let interactor = AccountModuleInteractorImpl(accountJID: jid,
                                                       keyChain: keyChain,
                                                       accountManager: accountManager)
        
        self.expectation(forNotification: KeyChainDidUpdateItemNotification,
                         object: keyChain,
                         handler: { (notification)->Bool in
                            if let userInfo = notification.userInfo,
                                let item = userInfo[KeyChainItemKey] as? KeyChainItem {
                                if jid == item.jid {
                                    return true
                                }
                            }
                            return false
        })
        
        try! interactor.update(options: ["foo":"bar"])
        
        self.waitForExpectations(timeout: 1.0, handler: nil)
        
        item = try! keyChain.item(jid: jid)
        XCTAssertEqual(item.options["foo"] as? String, "bar")
    }
    
    func testConnectAccount() {
        let jid = JID("romeo@example.com")!
        
        let keyChain = KeyChain(named: "AccountModuleInteractorImplTests")
        let item = KeyChainItem(jid: jid, invisible: false, options: [:])
        try! keyChain.add(item)
        
        let accountManager = TestAccountManager()
        let interactor = AccountModuleInteractorImpl(accountJID: jid,
                                                       keyChain: keyChain,
                                                       accountManager: accountManager)
        
        self.expectation(forNotification: "TestAccountManagerDidConnect",
                         object: accountManager,
                         handler: {(notification)->Bool in true})
        
        try! interactor.connect()
        
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    // Helper
    
    class TestAccountManager : AccountManager {
        
        override func info(for account: JID) -> AccountInfo? {
            return accountInfo
        }
        
        override func connect(_ account: JID) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TestAccountManagerDidConnect"),
                                              object: self)
        }
    }
    
    class TestAccountInfo : NSObject, AccountInfo {
        
        internal var connectionState: CoreXMPP.AccountConnectionState
        internal var recentError: NSError? {
            get { return nil }
        }
        internal var nextConnectionAttempt: Date? {
            get { return nil }
        }
        
        init(state: CoreXMPP.AccountConnectionState) {
            self.connectionState = state
        }
    }
}
