//
//  SettingsPresenter.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 12.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation
import Fountain
import IntercambioCore
import CoreXMPP

protocol SettingsPresenterEventHandler {
    func settingsDidCancel(_ settingsPresenter: SettingsPresenter) -> Void
    func settingsDidSave(_ settingsPresenter: SettingsPresenter) -> Void
}

class SettingsPresenter : SettingsViewEventHandler {
    
    var eventHandler: SettingsPresenterEventHandler?

    weak var view: SettingsView? {
        didSet {
            view?.dataSource = dataSource
        }
    }

    private let dataSource: SettingsDataSource

    init(accountJID: JID, keyChain: KeyChain) {
        dataSource = SettingsDataSource(accountJID: accountJID, keyChain: keyChain)
        do {
            try dataSource.reload()
        } catch {
            
        }
    }
    
    func save() {
        do {
            try dataSource.save()
            eventHandler?.settingsDidSave(self)
        } catch {
            
        }
    }
    
    func cancel() {
        eventHandler?.settingsDidCancel(self)
    }
    
    func setValue(_ value: Any?, forItemAt indexPath: IndexPath) {
        dataSource.setValue(value, forItemAt: indexPath)
    }
}
