//
//  FromSection.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 13.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation

public protocol FormSection {
    var title: String? { get }
    var instructions: String? { get }
}
