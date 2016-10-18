//
//  RecentConversationsPresenter.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 10.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import IntercambioCore

class RecentConversationsPresenter: NSObject, RecentConversationsViewEventHandler {
    
    weak public var router: RecentConversationsRouter?
    
    let dataSource: RecentConversationsDataSource
    
    weak var view: RecentConversationsView? {
        didSet {
            view?.dataSource = dataSource
        }
    }
    
    init(keyChain: KeyChain, db: RecentConversationsMessageDB) {
        self.dataSource = RecentConversationsDataSource(keyChain: keyChain, db: db)
    }
    
    func newConversation() {
        router?.presentNewConversationUserInterface()
    }
    
    func view(_ view: RecentConversationsView, didSelectItemAt indexPath: IndexPath) {
        if let uri = dataSource.conversationURI(at: indexPath) {
            router?.presentConversationUserInterface(for: uri)
        }
    }
}
