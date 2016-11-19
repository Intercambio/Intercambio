//
//  ConversationView.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 21.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit
import Fountain

enum ConversationViewModelDirection {
    case undefined
    case inbound
    case outbound
}

enum ConversationViewModelType: String {
    case chat = "chat"
    case error = "error"
    case groupchat = "groupchat"
    case headline = "headline"
    case normal = "normal"
}

protocol ConversationViewModel {
    var direction: ConversationViewModelDirection { get }
    var type: ConversationViewModelType { get }
    var origin: URL? { get }
    var editable: Bool { get }
    var temporary: Bool { get }
    var timestamp: Date? { get }
    var body: NSAttributedString? { get }
}

protocol ConversationView : class {
    var dataSource: FTDataSource? { get set }
    var title: String? { get set }
    var isContactPickerVisible: Bool { get set }
}
