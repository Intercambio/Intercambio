//
//  RecentConversationsView.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 10.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import Fountain

protocol RecentConversationsViewModel {
    var title: String? { get }
    var subtitle: String? { get }
    var body: String? { get }
    var dateString: String? { get }
    var avatarImage: UIImage? { get }
    var unread: Bool { get }
}

protocol RecentConversationsView : class {
    var dataSource: FTDataSource? { get set }
}
