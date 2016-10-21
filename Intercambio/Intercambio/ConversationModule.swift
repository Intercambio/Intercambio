//
//  ConversationModule.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 21.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import IntercambioCore

public class ConversationModule : NSObject {
    
    public let service: CommunicationService
    
    public init(service: CommunicationService) {
        self.service = service
    }
    
    public func viewController(uri: URL?) -> UIViewController? {
        let presenter = ConversationPresenter()
        let viewController = ConversationViewController()
        
        viewController.eventHandler = presenter
        presenter.view = viewController
        
        return viewController
    }
}
