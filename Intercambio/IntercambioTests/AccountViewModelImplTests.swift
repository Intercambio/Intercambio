//
//  AccountPresentationModelImplTests.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 01.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import XCTest
import IntercambioCore
import CoreXMPP
@testable import Intercambio

class AccountPresentationModelImplTests : XCTestCase {
    
    func test() {
        let item = KeyChainItem(jid: JID("romeo@example.com")!, invisible: false, options: [:])
        let model = AccountPresentationModelImpl(keyChainItem: item)
        XCTAssertEqual(model.identifier, "romeo@example.com")
    }
}
