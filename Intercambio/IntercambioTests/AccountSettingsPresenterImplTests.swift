//
//  AccountSettingsPresenterImplTests.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 11.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import XCTest
import CoreXMPP
@testable import Intercambio

class AccountSettingsPresenterImplTests: XCTestCase {
    
    internal class TestModel : AccountViewModel {
        var identifier: String = "undefined"
        var enabled: Bool = false
        var state: AccountConnectionState = AccountConnectionState.disconnected
        var name: String?
        var options: Dictionary<NSObject, AnyObject> = [:]
        var error: NSError?
        var nextConnectionAttempt: Date?
    }
    
    class TestUserInterface : NSObject, AccountSettingsUserInterface {
        var accountLabel: String?
        var stateLabel: String?
        var nextConnectionLabel: String? {
            didSet {
                NotificationCenter.default().post(name: NSNotification.Name(rawValue: "TestUserInterfaceDidChange"), object: self)
            }
        }
        var errorMessageLabel : String?
        var connectionButtonEnabled: Bool = false
        var connectionButtonHidden: Bool = false
        var nextConnectionLabelHidden: Bool = false
        var errorMessageLabelHidden: Bool = false
    }
    
    func testDisabledAccount() {
        
        let account = TestModel()
        let userInterface = TestUserInterface()
        
        let presenter = AccountSettingsPresenterImpl()
        presenter.userInterface = userInterface
        
        presenter.present(account: account)
        
        XCTAssertEqual(userInterface.accountLabel, "undefined")
        XCTAssertEqual(userInterface.stateLabel, "disabled")
        XCTAssertEqual(userInterface.nextConnectionLabel, nil)
        XCTAssertEqual(userInterface.errorMessageLabel, nil)
        XCTAssertTrue(userInterface.connectionButtonHidden)
        XCTAssertTrue(userInterface.nextConnectionLabelHidden)
        XCTAssertTrue(userInterface.errorMessageLabelHidden)
    }
    
    func testDisconnected() {
        let account = TestModel()
        let userInterface = TestUserInterface()
        
        let presenter = AccountSettingsPresenterImpl()
        presenter.userInterface = userInterface
        
        account.enabled = true
        account.state = .disconnected
        account.identifier = "My Account"
        
        presenter.present(account: account)
        
        XCTAssertEqual(userInterface.accountLabel, "My Account")
        XCTAssertEqual(userInterface.stateLabel, "disconnected")
        XCTAssertEqual(userInterface.nextConnectionLabel, nil)
        XCTAssertEqual(userInterface.errorMessageLabel, nil)
        XCTAssertFalse(userInterface.connectionButtonHidden)
        XCTAssertTrue(userInterface.connectionButtonEnabled)
        XCTAssertTrue(userInterface.nextConnectionLabelHidden)
        XCTAssertTrue(userInterface.errorMessageLabelHidden)
    }
    
    func testConnecting() {
        let account = TestModel()
        let userInterface = TestUserInterface()
        
        let presenter = AccountSettingsPresenterImpl()
        presenter.userInterface = userInterface
        
        account.enabled = true
        account.state = .connecting
        account.identifier = "My Account"
        
        presenter.present(account: account)
        
        XCTAssertEqual(userInterface.accountLabel, "My Account")
        XCTAssertEqual(userInterface.stateLabel, "connecting")
        XCTAssertEqual(userInterface.nextConnectionLabel, nil)
        XCTAssertEqual(userInterface.errorMessageLabel, nil)
        XCTAssertFalse(userInterface.connectionButtonHidden)
        XCTAssertFalse(userInterface.connectionButtonEnabled)
        XCTAssertTrue(userInterface.nextConnectionLabelHidden)
        XCTAssertTrue(userInterface.errorMessageLabelHidden)
    }
    
    func testConnected() {
        let account = TestModel()
        let userInterface = TestUserInterface()
        
        let presenter = AccountSettingsPresenterImpl()
        presenter.userInterface = userInterface
        
        account.enabled = true
        account.state = .connected
        account.identifier = "My Account"
        
        presenter.present(account: account)
        
        XCTAssertEqual(userInterface.accountLabel, "My Account")
        XCTAssertEqual(userInterface.stateLabel, "connected")
        XCTAssertEqual(userInterface.nextConnectionLabel, nil)
        XCTAssertEqual(userInterface.errorMessageLabel, nil)
        XCTAssertTrue(userInterface.connectionButtonHidden)
        XCTAssertFalse(userInterface.connectionButtonEnabled)
        XCTAssertTrue(userInterface.nextConnectionLabelHidden)
        XCTAssertTrue(userInterface.errorMessageLabelHidden)
    }
    
    func testError() {
        let account = TestModel()
        let userInterface = TestUserInterface()
        
        let presenter = AccountSettingsPresenterImpl()
        presenter.userInterface = userInterface
        
        account.enabled = true
        account.state = .disconnected
        account.error = NSError(domain: "My Domain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Connection Error."])
        
        presenter.present(account: account)
        
        XCTAssertFalse(userInterface.errorMessageLabelHidden)
        XCTAssertEqual(userInterface.errorMessageLabel, "Connection Error.")
    }
    
    func testNextConnection() {
        let account = TestModel()
        let userInterface = TestUserInterface()
        
        let presenter = AccountSettingsPresenterImpl()
        presenter.userInterface = userInterface
        
        account.enabled = true
        account.state = .disconnected
        account.nextConnectionAttempt = Date(timeIntervalSinceNow: 10)
        
        presenter.present(account: account)
        
        XCTAssertFalse(userInterface.nextConnectionLabelHidden)
        XCTAssertEqual(userInterface.nextConnectionLabel, "Reconnecting in 9 seconds …")
        
        self.expectation(forNotification: "TestUserInterfaceDidChange", object: userInterface) { (notification) -> Bool in
            return userInterface.nextConnectionLabel != "Reconnecting in 9 seconds …"
        }
        self.waitForExpectations(withTimeout: 2.0, handler: nil)
    }
}
