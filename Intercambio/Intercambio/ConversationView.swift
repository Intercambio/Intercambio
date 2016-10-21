//
//  ConversationView.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 21.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import Fountain

protocol ConversationViewModel {
}

protocol ConversationView : class {
    var dataSource: FTDataSource? { get set }
}
