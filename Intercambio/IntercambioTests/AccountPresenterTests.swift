//
//  AccountPresenterTests.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 11.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import XCTest
import CoreXMPP
@testable import Intercambio

class AccountPresenterTests: XCTestCase {
    
    internal class TestModel : AccountPresentationModel {
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
        var state: AccountPresentationModelConnectionState = AccountPresentationModelConnectionState.disconnected
        var name: String?
        var options: Dictionary<NSObject, AnyObject> = [:]
        var error: Error?
        var nextConnectionAttempt: Date?
    }
    
    class TestUserInterface : NSObject, AccountView {
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
    
    class TestInteractor : AccountProvider {
        var account: AccountPresentationModel? = TestModel()
        func enable() throws {}
        func disable() throws {}
        func connect() throws {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "TestInteractorConnect"), object: self)
        }
        func update(options: Dictionary<String, AnyObject>) throws {}
    }
    
    class TestRouter : AccountRouter {
        func presentSettingsUserInterface(for accountURI: URL) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "TestRouterShowSettings"), object: self, userInfo: ["uri": accountURI])
        }
    }
    
    func testDisabledAccount() {
        
        let account = TestModel()
        let view = TestUserInterface()
        
        let presenter = AccountPresenter()
        presenter.view = view
        
        presenter.present(account: account)
        
        XCTAssertEqual(view.accountLabel, "undefined")
        XCTAssertEqual(view.stateLabel, "disabled")
        XCTAssertEqual(view.nextConnectionLabel, nil)
        XCTAssertEqual(view.errorMessageLabel, nil)
        XCTAssertTrue(view.connectionButtonHidden)
    }
    
    func testDisconnected() {
        let account = TestModel()
        let view = TestUserInterface()
        
        let presenter = AccountPresenter()
        presenter.view = view
        
        account.enabled = true
        account.state = .disconnected
        account.identifier = "My Account"
        
        presenter.present(account: account)
        
        XCTAssertEqual(view.accountLabel, "My Account")
        XCTAssertEqual(view.stateLabel, "disconnected")
        XCTAssertEqual(view.nextConnectionLabel, nil)
        XCTAssertEqual(view.errorMessageLabel, nil)
        XCTAssertFalse(view.connectionButtonHidden)
        XCTAssertTrue(view.connectionButtonEnabled)
    }
    
    func testConnecting() {
        let account = TestModel()
        let view = TestUserInterface()
        
        let presenter = AccountPresenter()
        presenter.view = view
        
        account.enabled = true
        account.state = .connecting
        account.identifier = "My Account"
        
        presenter.present(account: account)
        
        XCTAssertEqual(view.accountLabel, "My Account")
        XCTAssertEqual(view.stateLabel, "connecting")
        XCTAssertEqual(view.nextConnectionLabel, nil)
        XCTAssertEqual(view.errorMessageLabel, nil)
        XCTAssertFalse(view.connectionButtonHidden)
        XCTAssertFalse(view.connectionButtonEnabled)
    }
    
    func testConnected() {
        let account = TestModel()
        let view = TestUserInterface()
        
        let presenter = AccountPresenter()
        presenter.view = view
        
        account.enabled = true
        account.state = .connected
        account.identifier = "My Account"
        
        presenter.present(account: account)
        
        XCTAssertEqual(view.accountLabel, "My Account")
        XCTAssertEqual(view.stateLabel, "connected")
        XCTAssertEqual(view.nextConnectionLabel, nil)
        XCTAssertEqual(view.errorMessageLabel, nil)
        XCTAssertTrue(view.connectionButtonHidden)
        XCTAssertFalse(view.connectionButtonEnabled)
    }
    
    func testError() {
        let account = TestModel()
        let view = TestUserInterface()
        
        let presenter = AccountPresenter()
        presenter.view = view
        
        account.enabled = true
        account.state = .disconnected
        account.error = NSError(domain: "My Domain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Connection Error."])
        
        presenter.present(account: account)
        
        XCTAssertEqual(view.errorMessageLabel, "Connection Error.")
    }
    
    func testNextConnection() {
        let account = TestModel()
        let view = TestUserInterface()
        
        let presenter = AccountPresenter()
        presenter.view = view
        
        account.enabled = true
        account.state = .disconnected
        account.nextConnectionAttempt = Date(timeIntervalSinceNow: 10)
        
        presenter.present(account: account)
        
        XCTAssertEqual(view.nextConnectionLabel, "Reconnecting in 9 seconds …")
        
        self.expectation(forNotification: "TestUserInterfaceDidChange", object: view) { (notification) -> Bool in
            return view.nextConnectionLabel != "Reconnecting in 9 seconds …"
        }
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func testConnectAccount() {
        
        let interactor = TestInteractor()
        
        let presenter = AccountPresenter()
        presenter.interactor = interactor
        
        self.expectation(forNotification: "TestInteractorConnect",
                         object: interactor) { (n) -> Bool in true }
        
        presenter.connectAccount()
        
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testShowSettings() {
        
        let router = TestRouter()
        let interactor = TestInteractor()
        
        let presenter = AccountPresenter()
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
        
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }
}
