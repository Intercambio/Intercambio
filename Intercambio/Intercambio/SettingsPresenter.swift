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
    func settingsDidRemove(_ settingsPresenter: SettingsPresenter) -> Void
}

class SettingsPresenter : SettingsViewEventHandler, SettingsDataSourceDelegate {
    
    var eventHandler: SettingsPresenterEventHandler?

    weak var view: SettingsView? {
        didSet {
            view?.dataSource = dataSource
        }
    }

    private let dataSource: SettingsDataSource
    
    var accountJID: JID {
        return dataSource.accountJID
    }
    
    init(accountJID: JID, keyChain: KeyChain) {
        dataSource = SettingsDataSource(accountJID: accountJID, keyChain: keyChain)
        dataSource.delegate = self
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
    
    func performAction(_ action: Selector, forItemAt indexPath: IndexPath) {
        dataSource.performAction(action, forItemAt: indexPath)
    }
    
    // SettingsDataSourceDelegate
    
    func settingsDataSource(_ dataSource: SettingsDataSource, didRemoveAccount jid: JID) {
        eventHandler?.settingsDidRemove(self)
    }
}
