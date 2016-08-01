//
//  SettingsPresenterTests.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 12.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import XCTest
import IntercambioCore
import CoreXMPP
@testable import Intercambio

class SettingsPresenterTests: XCTestCase {

    class Interactor : SettingsProvider {
        var accountURI: URL? { get { return URL(string: "xmpp://romeo@example.com")! } }
        var identifier: String { get { return "romeo@example.com" } }
        var settings: Settings { get { return Settings() }}
        var updateSettings: Settings?
        func update(settings: Settings) throws {
            updateSettings = settings
        }
    }
    
    class UserInterface : SettingsView {
        var identifier: String?
        var dataSource: FTDataSource?
    }
    
    // Tests
    
    func testLoadSettings() {
        
        let interactor = Interactor()
        let userInterface = UserInterface()
        let presenter = SettingsPresenter()
        presenter.userInterface = userInterface
        presenter.interactor = interactor
        
        presenter.loadSettings()
        
        XCTAssertNotNil(userInterface.dataSource)
        if let dataSource = userInterface.dataSource {
            
            XCTAssertEqual(dataSource.numberOfSections(), 1)
            XCTAssertEqual(dataSource.numberOfItems(inSection: 0), 1)
            
            let section = dataSource.sectionItem(forSection: 0) as? FormSection
            XCTAssertNotNil(section)
            XCTAssertEqual(section?.title, "Websocket URL")
            XCTAssertNotNil(section?.instructions)
            
            if let item = dataSource.item(at: IndexPath(indexes: [0, 0])) as? FormItem<URL> {
                XCTAssertNotNil(item)
                XCTAssertEqual(item.identifier, "websocketURL")
            } else {
                XCTFail()
            }
        }
    }
    
    func testSave() {

        let interactor = Interactor()
        let userInterface = UserInterface()
        let presenter = SettingsPresenter()
        presenter.userInterface = userInterface
        presenter.interactor = interactor
        
        presenter.loadSettings()
        
        if let item = userInterface.dataSource?.item(at: IndexPath(indexes: [0, 0])) as? FormItem<URL> {
            XCTAssertNotNil(item)
            XCTAssertEqual(item.identifier, "websocketURL")
            item.value = URL(string: "wws://example.com")
        } else {
            XCTFail()
        }
        
        try! presenter.save()
        
        XCTAssertNotNil(interactor.updateSettings)
        XCTAssertEqual(interactor.updateSettings?.websocketURL, URL(string: "wws://example.com"))
    }
}
