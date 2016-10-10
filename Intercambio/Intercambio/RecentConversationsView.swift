//
//  RecentConversationsView.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 10.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation
import Fountain

protocol RecentConversationsView : class {
    var dataSource: FTDataSource? { get set }
}
