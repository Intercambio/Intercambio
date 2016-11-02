//
//  RecentConversations.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 16.09.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import IntercambioCore

@objc public protocol RecentConversationsRouter : class {
    func presentConversationUserInterface(for conversationURI: URL)
    func presentNewConversationUserInterface()
}

public class RecentConversationsModule : NSObject {
    
    public let service: CommunicationService
    weak public var router: RecentConversationsRouter?
    
    public init(service: CommunicationService) {
        self.service = service
    }
    
    public func viewController() -> RecentConversationsViewController {
        let presenter = RecentConversationsPresenter(keyChain: service.keyChain, db: service.messageDB)
        let viewController = RecentConversationsViewController()
    
        viewController.eventHandler = presenter
        presenter.view = viewController
        presenter.router = router
        
        return viewController
    }
}

extension XMPPMessageDB : RecentConversationsMessageDB {}
