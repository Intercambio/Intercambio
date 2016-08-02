//
//  FormItem.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 13.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation

public class FormItem<T> {
    public let identifier: String
    public var label: String?
    public var value: T?
    init(identifier: String) {
        self.identifier = identifier
    }
}
