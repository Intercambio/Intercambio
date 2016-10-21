//
//  ConversationViewController.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 21.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import Fountain

class ConversationViewController: UIViewController, ConversationView {

    var eventHandler: ConversationViewEventHandler?
    var dataSource: FTDataSource? {
        didSet {
            
        }
    }
    
}
