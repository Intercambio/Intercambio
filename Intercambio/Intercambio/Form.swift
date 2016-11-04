//
//  Form.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 03.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

public protocol FormItem {
    var identifier: String { get }
    var selectable: Bool { get }
}

public protocol FormValueItem : FormItem {
    var title: String? { get }
    var value: String? { get }
    var icon: UIImage? { get }
    var hasDetails: Bool { get }
}

public protocol FormTextItem : FormItem {
    var placeholder: String? { get }
    var text: String? { get }
}

public protocol FormURLItem : FormItem {
    var placeholder: String? { get }
    var url: URL? { get }
}

public protocol FormSection {
    var title: String? { get }
    var instructions: String? { get }
}
