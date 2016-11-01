//
//  ConversationModule.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 21.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import IntercambioCore
import XMPPMessageArchive

public class ConversationModule : NSObject {
    
    public let service: CommunicationService
    
    public init(service: CommunicationService) {
        self.service = service
    }
    
    public var contactPicker: ContactPickerModule?
    
    public func viewController(uri: URL?) -> UIViewController? {
        let presenter = ConversationPresenter(db: service.messageDB)
        let viewController = ConversationViewController()
        
        presenter.view = viewController
        presenter.conversation = uri
        
        viewController.eventHandler = presenter
        if uri == nil {
            viewController.contactPickerViewController = contactPicker?.viewController { url in
                presenter.conversation = url
            }
            viewController.isContactPickerVisible = true
        }
        
        return viewController
    }
}

extension XMPPMessageDB : ConversationMessageDB {}
