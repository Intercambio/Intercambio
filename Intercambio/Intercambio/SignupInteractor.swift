//
//  SignupInteractor.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 03.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation
import KeyChain
import XMPPFoundation

class SignupInteractor {
    
    let keyChain: KeyChain
    init(keyChain: KeyChain) {
        self.keyChain = keyChain
    }
    
    func addAccount(_ jid: JID) {
        if jid.host.characters.count > 0 && jid.user != nil && jid.user!.characters.count > 0 {
            
            let options: [AnyHashable: Any] = [:]
            let item = KeyChainItem(identifier: jid.stringValue,
                                    invisible: false,
                                    options: options)
            
            do {
                try keyChain.add(item)
            } catch {
                
            }
        }
    }
}
