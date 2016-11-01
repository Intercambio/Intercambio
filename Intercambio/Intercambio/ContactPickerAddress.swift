//
//  ContactPickerAddress.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 01.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation
import CoreXMPP

class ContactPickerAddress : NSObject {
    
    var title: String { return jid.stringValue }
    var identifier: String { return jid.stringValue }

    let jid: JID
    init(_ jid: JID) {
        self.jid = jid
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? ContactPickerAddress {
            return other.jid.isEqual(jid)
        } else {
            return false
        }
    }
}
