//
//  RecentConversationsView.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 10.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import Fountain

enum RecentConversationsViewModelType: String {
    case chat = "chat"
    case error = "error"
    case groupchat = "groupchat"
    case headline = "headline"
    case normal = "normal"
}

protocol RecentConversationsViewModel {
    var type: RecentConversationsViewModelType { get }
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
