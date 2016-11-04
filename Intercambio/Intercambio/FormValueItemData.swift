//
//  FormValueItemData.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 04.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

public class FormValueItemData : FormValueItem {
    
    public var selectable: Bool = false
    public var title: String?
    public var value: String?
    public var icon: UIImage?
    public var hasDetails: Bool = false
    
    public let identifier: String
    init(identifier: String) {
        self.identifier = identifier
    }
}
