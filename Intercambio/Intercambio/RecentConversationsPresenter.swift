//
//  RecentConversationsPresenter.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 10.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

class RecentConversationsPresenter: NSObject, RecentConversationsViewEventHandler {
    
    weak var view: RecentConversationsView? {
        didSet {
            view?.dataSource = nil
        }
    }
    
    func view(_ view: RecentConversationsView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
