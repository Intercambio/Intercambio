//
//  AccountModulePresenterImplTests.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 11.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import XCTest
import CoreXMPP
@testable import Intercambio

class AccountModulePresenterImplTests: XCTestCase {
    
    internal class TestModel : AccountViewModel {
        var identifier: String = "undefined"
        var accountURI: URL? {
            get {
                var components = URLComponents()
                components.scheme = "xmpp"
                components.host = "example.com"
                components.user = "romeo"
                return components.url
            }
        }
        var enabled: Bool = false
        var state: AccountConnectionState = AccountConnectionState.disconnected
        var name: String?
        var options: Dictionary<NSObject, AnyObject> = [:]
        var error: NSError?
        var nextConnectionAttempt: Date?
    }
    
    class TestUserInterface : NSObject, AccountModuleUserInterface {
        var accountLabel: String?
        var stateLabel: String?
        var nextConnectionLabel: String? {
            didSet {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TestUserInterfaceDidChange"), object: self)
            }
        }
        var errorMessageLabel : String?
        var connectionButtonEnabled: Bool = false
        var connectionButtonHidden: Bool = false
    }
    
    class TestInteractor : AccountModuleInteractor {
        var account: AccountViewModel? = TestModel()
        func enable() throws {}
        func disable() throws {}
        func connect() throws {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "TestInteractorConnect"), object: self)
        }
        func update(options: Dictionary<String, AnyObject>) throws {}
    }
    
    class TestRouter : AccountModuleRouter {
        func presentSettingsUserInterface(for accountURI: URL) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "TestRouterShowSettings"), object: self, userInfo: ["uri": accountURI])
        }
    }
    
    func testDisabledAccount() {
        
        let account = TestModel()
        let userInterface = TestUserInterface()
        
        let presenter = AccountModulePresenterImpl()
        presenter.userInterface = userInterface
        
        presenter.present(account: account)
        
        XCTAssertEqual(userInterface.accountLabel, "undefined")
        XCTAssertEqual(userInterface.stateLabel, "disabled")
        XCTAssertEqual(userInterface.nextConnectionLabel, nil)
        XCTAssertEqual(userInterface.errorMessageLabel, nil)
        XCTAssertTrue(userInterface.connectionButtonHidden)
    }
    
    func testDisconnected() {
        let account = TestModel()
        let userInterface = TestUserInterface()
        
        let presenter = AccountModulePresenterImpl()
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
    }
    
    func testConnecting() {
        let account = TestModel()
        let userInterface = TestUserInterface()
        
        let presenter = AccountModulePresenterImpl()
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
    }
    
    func testConnected() {
        let account = TestModel()
        let userInterface = TestUserInterface()
        
        let presenter = AccountModulePresenterImpl()
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
    }
    
    func testError() {
        let account = TestModel()
        let userInterface = TestUserInterface()
        
        let presenter = AccountModulePresenterImpl()
        presenter.userInterface = userInterface
        
        account.enabled = true
        account.state = .disconnected
        account.error = NSError(domain: "My Domain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Connection Error."])
        
        presenter.present(account: account)
        
        XCTAssertEqual(userInterface.errorMessageLabel, "Connection Error.")
    }
    
    func testNextConnection() {
        let account = TestModel()
        let userInterface = TestUserInterface()
        
        let presenter = AccountModulePresenterImpl()
        presenter.userInterface = userInterface
        
        account.enabled = true
        account.state = .disconnected
        account.nextConnectionAttempt = Date(timeIntervalSinceNow: 10)
        
        presenter.present(account: account)
        
        XCTAssertEqual(userInterface.nextConnectionLabel, "Reconnecting in 9 seconds …")
        
        self.expectation(forNotification: "TestUserInterfaceDidChange", object: userInterface) { (notification) -> Bool in
            return userInterface.nextConnectionLabel != "Reconnecting in 9 seconds …"
        }
        self.waitForExpectations(withTimeout: 2.0, handler: nil)
    }
    
    func testConnectAccount() {
        
        let interactor = TestInteractor()
        
        let presenter = AccountModulePresenterImpl()
        presenter.interactor = interactor
        
        self.expectation(forNotification: "TestInteractorConnect",
                         object: interactor) { (n) -> Bool in true }
        
        presenter.connectAccount()
        
        self.waitForExpectations(withTimeout: 1.0, handler: nil)
    }
    
    func testShowSettings() {
        
        let router = TestRouter()
        let interactor = TestInteractor()
        
        let presenter = AccountModulePresenterImpl()
        presenter.interactor = interactor
        presenter.router = router
        
        self.expectation(forNotification: "TestRouterShowSettings", object: router) {
            (notification) -> Bool in
            if let userInfo = notification.userInfo,
                let uri = userInfo["uri"] as? URL {
                XCTAssertEqual(uri.scheme, "xmpp")
                XCTAssertEqual(uri.host, "example.com")
                XCTAssertEqual(uri.user, "romeo")
                if uri.absoluteString == "xmpp://romeo@example.com"  {
                    return true
                }
            }
            return false
        }
        
        presenter.showAccountSettings()
        
        self.waitForExpectations(withTimeout: 1.0, handler: nil)
    }
}
