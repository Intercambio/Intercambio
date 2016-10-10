//
//  RecentConversationsViewEventHandler.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 10.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation

protocol RecentConversationsViewEventHandler: class {
    func view(_ view: RecentConversationsView, didSelectItemAt indexPath: IndexPath) -> Void
}
