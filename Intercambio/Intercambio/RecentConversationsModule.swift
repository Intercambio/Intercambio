//
//  RecentConversations.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 16.09.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import IntercambioCore
import XMPPMessageHub

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
    
    public func makeRecentConversationsViewController() -> RecentConversationsViewController {
        let controller = RecentConversationsViewController(service: service)
        controller.router = router
        return controller
    }
}

public extension RecentConversationsViewController {
    
    public convenience init(service: CommunicationService) {
        self.init()
        let presenter = RecentConversationsPresenter(keyChain: service.keyChain, archiveManager: service.messageHub)
        presenter.view = self
        self.presenter = presenter
    }
    
    public var router: RecentConversationsRouter? {
        set {
            if let presenter = self.presenter as? RecentConversationsPresenter {
                presenter.router = newValue
            }
        }
        get {
            if let presenter = self.presenter as? RecentConversationsPresenter {
                return presenter.router
            } else {
                return nil
            }
        }
    }
}
