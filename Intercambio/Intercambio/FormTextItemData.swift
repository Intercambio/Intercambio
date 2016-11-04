//
//  FormTextItemData.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 04.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation

public class FormTextItemData : FormTextItem {
    
    public var selectable: Bool = false
    public var placeholder: String?
    public var text: String?
    
    public let identifier: String
    init(identifier: String) {
        self.identifier = identifier
    }
}
