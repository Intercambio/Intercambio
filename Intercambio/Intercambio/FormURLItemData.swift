//
//  FormURLItemData.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 13.07.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation

public class FormURLItemData : FormURLItem {
    
    public var selectable: Bool = false
    public var placeholder: String?
    public var url: URL?
    
    public let identifier: String
    init(identifier: String) {
        self.identifier = identifier
    }
}
