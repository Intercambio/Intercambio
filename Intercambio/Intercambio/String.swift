//
//  String.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 05.12.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation

public extension UnicodeScalar {
    public var isEmoji: Bool {
        // TODO: Add more code point ranges
        return value >= 0x1F300 && value <= 0x1F5FF
    }
}
