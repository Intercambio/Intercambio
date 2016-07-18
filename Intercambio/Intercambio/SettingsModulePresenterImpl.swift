//
//  SettingsModulePresenterImpl.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 12.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation
import Fountain

public class SettingsModulePresenterImpl : SettingsModulePresenter, SettingsModuleEventHandler {
    
    internal weak var userInterface: SettingsModuleUserInterface? {
        didSet {
            updateIdentifier()
        }
    }
    internal var interactor: SettingsModuleInteractor? {
        didSet {
            updateIdentifier()
        }
    }
    
    private var dataSource: FTDataSource?
    
    public func loadSettings() {
        if let interactor = self.interactor {
            dataSource = dataSource(settings: interactor.settings)
        } else {
            dataSource = nil
        }
        userInterface?.dataSource = dataSource
    }
    
    public func save() throws {
        if let dataSource = self.dataSource {
            let settings = toSettings(dataSource: dataSource)
            try interactor?.update(settings: settings)
        }
    }
    
    private func dataSource(settings: Settings) -> FTDataSource {
        
        let section = FormSectionDataSource()
        section.title = "Websocket URL"
        section.instructions = "Websockt URL that should be used."
        
        let item = FormItem<URL>(identifier: "websocketURL")
        item.label = "Automatic Discovery"
        item.value = settings.websocketURL
        section.add(item)
        
        let dataSource = FormDataSource(dataSources: [section])
        
        return dataSource!
    }
    
    private func toSettings(dataSource: FTDataSource) -> Settings {
        
        var settings = Settings()
        
        let numberOfSection = dataSource.numberOfSections()
        for section in 0..<numberOfSection {
            
            let numberOfItems = dataSource.numberOfItems(inSection: section)
            for item in 0..<numberOfItems {
                
                let indexPath = IndexPath(indexes: [Int(section), Int(item)])
                let item = dataSource.item(at: indexPath)
                
                if let formItem = item as? FormItem<URL> {
                    if formItem.identifier == "websocketURL" {
                        settings.websocketURL = formItem.value
                    }
                }
            }
        }
        
        return settings
    }
    
    private func updateIdentifier() {
        userInterface?.identifier = interactor?.identifier
    }
}
