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
    
    public func viewController(uri: URL?) -> UIViewController? {
        let presenter = ConversationPresenter(db: service.messageDB)
        let viewController = ConversationViewController()
        
        viewController.eventHandler = presenter
        presenter.view = viewController
        
        presenter.conversation = uri
        
        return viewController
    }
}

extension XMPPMessageDB : ConversationMessageDB {}
