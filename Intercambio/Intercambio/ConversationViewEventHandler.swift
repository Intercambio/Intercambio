//
//  ConversationViewEventHandler.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 21.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation

protocol ConversationViewEventHandler: class {
    func setValue(_ value: Any, forItemAt indexPath: IndexPath)
}
