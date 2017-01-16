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
    
    var router: RecentConversationsRouter?
    weak var view: RecentConversationsView? {
        didSet {
            view?.dataSource = dataSource
        }
    }
    
    let dataSource: RecentConversationsDataSource
    
    init(keyChain: KeyChain, archiveManager: ArchiveManager) {
        self.dataSource = RecentConversationsDataSource(keyChain: keyChain, archiveManager: archiveManager)
    }
    
    func newConversation() {
        router?.presentNewConversationUserInterface()
    }
    
    func view(_ view: RecentConversationsView, didSelectItemAt indexPath: IndexPath) {
        if let uri = dataSource.conversationURI(forItemAt: indexPath) {
            router?.presentConversationUserInterface(for: uri)
        }
    }
}
