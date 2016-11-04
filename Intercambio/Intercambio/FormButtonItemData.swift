//
//  FormButtonItemData.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 04.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

public class FormButtonItemData : FormButtonItem {
    
    public var selectable: Bool = false
    public var title: String?
    public var enabled: Bool = true
    public var destructive: Bool = false
    public var destructionMessage: String?
    
    public let identifier: String
    public var action: Selector
    init(identifier: String, action: Selector) {
        self.identifier = identifier
        self.action = action
    }
}
