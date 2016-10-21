//
//  ConversationPresenter.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 21.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import IntercambioCore

class ConversationPresenter: NSObject, ConversationViewEventHandler {

    weak var view: ConversationView? {
        didSet {
            view?.dataSource = nil
        }
    }
    
}
