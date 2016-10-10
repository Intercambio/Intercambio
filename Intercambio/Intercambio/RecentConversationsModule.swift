//
//  RecentConversations.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 16.09.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import IntercambioCore

public class RecentConversationsModule : NSObject {
    
    public let service: CommunicationService
    
    public init(service: CommunicationService) {
        self.service = service
    }
    
    public func viewController() -> (UIViewController?) {
        
        let presenter = RecentConversationsPresenter()
        let viewController = RecentConversationsViewController()
        
        viewController.eventHandler = presenter
        presenter.view = viewController
        
        return viewController
    }
}
