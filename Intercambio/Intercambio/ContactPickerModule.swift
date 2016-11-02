//
//  ContactPickerModule.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 30.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import IntercambioCore

public class ContactPickerModule : NSObject {
    
    public let service: CommunicationService
    
    public init(service: CommunicationService) {
        self.service = service
    }

    public func viewController(callback: @escaping (URL?) -> ()) -> ContactPickerViewController {
        let presenter = ContactPickerPresenter(accountManager: service.accountManager)
        let view = ContactPickerViewController()
        
        view.eventHandler = presenter
        presenter.view = view
        presenter.callback = callback
        
        return view
    }
}
